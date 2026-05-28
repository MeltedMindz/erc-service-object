// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {IERCServiceObject} from "../interfaces/IERCServiceObject.sol";
import {IERCServiceObjectController} from "../interfaces/IERCServiceObjectController.sol";

/// @title TokenizedAutonomousService
/// @notice Reference ERC-721 implementation of the ERC Service Object candidate.
contract TokenizedAutonomousService is ERC721, EIP712, IERCServiceObjectController, IERC4906 {
    error NotServiceOwner();
    error NotServiceOwnerOrOperator();
    error InvalidService();
    error InvalidRecipient();
    error InvalidReceipt();
    error DuplicateReceipt();

    struct ServiceData {
        address account;
        address operator;
        uint64 operatorExpiresAt;
        uint64 routeNonce;
        uint64 issuerEpoch;
        address revenueRecipient;
        string manifestURI;
        bytes32 manifestHash;
        string paymentManifestURI;
        bytes32 paymentManifestHash;
    }

    bytes32 public constant SERVICE_RECEIPT_TYPEHASH = keccak256(
        "ServiceReceipt(address serviceContract,uint256 serviceId,address payer,address issuer,address revenueRecipient,bytes32 requestHash,bytes32 responseHash,bytes32 paymentHash,bytes32 paymentManifestHash,bytes32 receiptURIHash,uint64 routeNonce,uint64 issuerEpoch,uint64 issuedAt)"
    );

    uint256 private _nextServiceId = 1;
    mapping(uint256 serviceId => ServiceData serviceData) private _services;
    mapping(uint256 serviceId => mapping(address issuer => uint64 epoch)) private _receiptIssuerEpoch;
    mapping(uint256 serviceId => mapping(bytes32 receiptHash => bool anchored)) private _anchoredReceipts;

    constructor() ERC721("Tokenized Autonomous Service", "TAS") EIP712("TokenizedAutonomousService", "1") {}

    /// @notice Mints a service token and initializes its manifest and payment route.
    function mintService(
        address to,
        string calldata manifestURI,
        bytes32 manifestHash,
        string calldata paymentManifestURI,
        bytes32 paymentManifestHash
    ) external returns (uint256 serviceId) {
        if (to == address(0)) revert InvalidRecipient();

        serviceId = _nextServiceId++;
        ServiceData storage serviceData = _services[serviceId];
        serviceData.revenueRecipient = to;
        serviceData.manifestURI = manifestURI;
        serviceData.manifestHash = manifestHash;
        serviceData.paymentManifestURI = paymentManifestURI;
        serviceData.paymentManifestHash = paymentManifestHash;
        serviceData.routeNonce = 1;
        serviceData.issuerEpoch = 1;

        _safeMint(to, serviceId);

        emit ServiceRevenueRecipientUpdated(serviceId, to, serviceData.routeNonce);
        emit ServiceManifestUpdated(serviceId, manifestURI, manifestHash);
        emit ServicePaymentManifestUpdated(serviceId, paymentManifestURI, paymentManifestHash, serviceData.routeNonce);
    }

    function setServiceAccount(uint256 serviceId, address account) external onlyServiceOwner(serviceId) {
        _services[serviceId].account = account;
        _services[serviceId].issuerEpoch++;
        emit ServiceAccountUpdated(serviceId, account);
    }

    function setServiceOperator(uint256 serviceId, address operator, uint64 expiresAt)
        external
        onlyServiceOwner(serviceId)
    {
        _services[serviceId].operator = operator;
        _services[serviceId].operatorExpiresAt = expiresAt;
        _services[serviceId].issuerEpoch++;
        emit ServiceOperatorUpdated(serviceId, operator, expiresAt);
    }

    function setServiceRevenueRecipient(uint256 serviceId, address recipient) external onlyServiceOwner(serviceId) {
        if (recipient == address(0)) revert InvalidRecipient();
        ServiceData storage serviceData = _services[serviceId];
        serviceData.revenueRecipient = recipient;
        serviceData.routeNonce++;
        emit ServiceRevenueRecipientUpdated(serviceId, recipient, serviceData.routeNonce);
    }

    function setServiceManifest(uint256 serviceId, string calldata uri, bytes32 manifestHash)
        external
        onlyServiceOwnerOrOperator(serviceId)
    {
        ServiceData storage serviceData = _services[serviceId];
        serviceData.manifestURI = uri;
        serviceData.manifestHash = manifestHash;
        emit ServiceManifestUpdated(serviceId, uri, manifestHash);
        emit MetadataUpdate(serviceId);
    }

    function setServicePaymentManifest(uint256 serviceId, string calldata uri, bytes32 manifestHash)
        external
        onlyServiceOwner(serviceId)
    {
        ServiceData storage serviceData = _services[serviceId];
        serviceData.paymentManifestURI = uri;
        serviceData.paymentManifestHash = manifestHash;
        serviceData.routeNonce++;
        emit ServicePaymentManifestUpdated(serviceId, uri, manifestHash, serviceData.routeNonce);
    }

    function setServiceReceiptIssuer(uint256 serviceId, address issuer, bool approved)
        external
        onlyServiceOwner(serviceId)
    {
        if (issuer == address(0)) revert InvalidRecipient();
        uint64 epoch = _services[serviceId].issuerEpoch + 1;
        _services[serviceId].issuerEpoch = epoch;
        _receiptIssuerEpoch[serviceId][issuer] = approved ? epoch : 0;
        emit ServiceReceiptIssuerUpdated(serviceId, issuer, approved, _services[serviceId].issuerEpoch);
    }

    function anchorServiceReceipt(ServiceReceipt calldata receipt, bytes calldata signature, string calldata receiptURI)
        external
        returns (bytes32 receiptHash)
    {
        if (receipt.receiptURIHash != keccak256(bytes(receiptURI))) revert InvalidReceipt();
        if (!verifyServiceReceipt(receipt, signature)) revert InvalidReceipt();

        receiptHash = hashServiceReceipt(receipt);
        if (_anchoredReceipts[receipt.serviceId][receiptHash]) revert DuplicateReceipt();

        _anchoredReceipts[receipt.serviceId][receiptHash] = true;
        emit ServiceReceiptAnchored(
            receipt.serviceId,
            receiptHash,
            receipt.issuer,
            receipt.payer,
            receipt.paymentHash,
            receipt.requestHash,
            receiptURI
        );
    }

    function serviceAccount(uint256 serviceId) external view returns (address) {
        _requireMinted(serviceId);
        return _services[serviceId].account;
    }

    function serviceOperator(uint256 serviceId) external view returns (address operator, uint64 expiresAt) {
        _requireMinted(serviceId);
        ServiceData storage serviceData = _services[serviceId];
        return (serviceData.operator, serviceData.operatorExpiresAt);
    }

    function serviceRevenueRecipient(uint256 serviceId) external view returns (address) {
        _requireMinted(serviceId);
        return _services[serviceId].revenueRecipient;
    }

    function serviceManifest(uint256 serviceId) external view returns (string memory uri, bytes32 manifestHash) {
        _requireMinted(serviceId);
        ServiceData storage serviceData = _services[serviceId];
        return (serviceData.manifestURI, serviceData.manifestHash);
    }

    function tokenURI(uint256 serviceId) public view override returns (string memory) {
        _requireMinted(serviceId);
        return _services[serviceId].manifestURI;
    }

    function servicePaymentManifest(uint256 serviceId)
        external
        view
        returns (string memory uri, bytes32 manifestHash, uint64 routeNonce)
    {
        _requireMinted(serviceId);
        ServiceData storage serviceData = _services[serviceId];
        return (serviceData.paymentManifestURI, serviceData.paymentManifestHash, serviceData.routeNonce);
    }

    function isAuthorizedReceiptIssuer(uint256 serviceId, address issuer) public view returns (bool) {
        if (_ownerOf(serviceId) == address(0) || issuer == address(0)) return false;

        ServiceData storage serviceData = _services[serviceId];
        if (issuer == serviceData.account && serviceData.account != address(0)) return true;
        if (issuer == serviceData.operator && _isOperatorActive(serviceData)) return true;
        return _receiptIssuerEpoch[serviceId][issuer] == serviceData.issuerEpoch;
    }

    function hashServiceReceipt(ServiceReceipt calldata receipt) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                SERVICE_RECEIPT_TYPEHASH,
                receipt.serviceContract,
                receipt.serviceId,
                receipt.payer,
                receipt.issuer,
                receipt.revenueRecipient,
                receipt.requestHash,
                receipt.responseHash,
                receipt.paymentHash,
                receipt.paymentManifestHash,
                receipt.receiptURIHash,
                receipt.routeNonce,
                receipt.issuerEpoch,
                receipt.issuedAt
            )
        );
        return _hashTypedDataV4(structHash);
    }

    function verifyServiceReceipt(ServiceReceipt calldata receipt, bytes calldata signature)
        public
        view
        returns (bool)
    {
        if (receipt.serviceContract != address(this)) return false;
        if (_ownerOf(receipt.serviceId) == address(0)) return false;

        ServiceData storage serviceData = _services[receipt.serviceId];
        if (receipt.revenueRecipient != serviceData.revenueRecipient) return false;
        if (receipt.paymentManifestHash != serviceData.paymentManifestHash) return false;
        if (receipt.routeNonce != serviceData.routeNonce) return false;
        if (receipt.issuerEpoch != serviceData.issuerEpoch) return false;
        if (!isAuthorizedReceiptIssuer(receipt.serviceId, receipt.issuer)) return false;

        return SignatureChecker.isValidSignatureNow(receipt.issuer, hashServiceReceipt(receipt), signature);
    }

    function isReceiptAnchored(uint256 serviceId, bytes32 receiptHash) external view returns (bool) {
        return _anchoredReceipts[serviceId][receiptHash];
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return interfaceId == type(IERC4906).interfaceId || interfaceId == type(IERCServiceObject).interfaceId
            || interfaceId == type(IERCServiceObjectController).interfaceId || super.supportsInterface(interfaceId);
    }

    modifier onlyServiceOwner(uint256 serviceId) {
        if (ownerOf(serviceId) != msg.sender) revert NotServiceOwner();
        _;
    }

    modifier onlyServiceOwnerOrOperator(uint256 serviceId) {
        if (ownerOf(serviceId) != msg.sender && !_isActiveOperator(serviceId, msg.sender)) {
            revert NotServiceOwnerOrOperator();
        }
        _;
    }

    function _isActiveOperator(uint256 serviceId, address operator) internal view returns (bool) {
        ServiceData storage serviceData = _services[serviceId];
        return operator == serviceData.operator && _isOperatorActive(serviceData);
    }

    function _isOperatorActive(ServiceData storage serviceData) internal view returns (bool) {
        return serviceData.operator != address(0)
            && (serviceData.operatorExpiresAt == 0 || serviceData.operatorExpiresAt >= block.timestamp);
    }

    function _requireMinted(uint256 serviceId) internal view {
        if (_ownerOf(serviceId) == address(0)) revert InvalidService();
    }

    function _update(address to, uint256 serviceId, address auth) internal override returns (address previousOwner) {
        address from = _ownerOf(serviceId);
        previousOwner = super._update(to, serviceId, auth);

        if (from != address(0) && to != address(0) && from != to) {
            _resetServiceRights(serviceId, to);
        } else if (to == address(0)) {
            delete _services[serviceId];
        }
    }

    function _resetServiceRights(uint256 serviceId, address newOwner) internal {
        ServiceData storage serviceData = _services[serviceId];
        serviceData.account = address(0);
        serviceData.operator = address(0);
        serviceData.operatorExpiresAt = 0;
        serviceData.revenueRecipient = newOwner;
        serviceData.paymentManifestURI = "";
        serviceData.paymentManifestHash = bytes32(0);
        serviceData.routeNonce++;
        serviceData.issuerEpoch++;

        emit ServiceAccountUpdated(serviceId, address(0));
        emit ServiceOperatorUpdated(serviceId, address(0), 0);
        emit ServiceRevenueRecipientUpdated(serviceId, newOwner, serviceData.routeNonce);
        emit ServicePaymentManifestUpdated(serviceId, "", bytes32(0), serviceData.routeNonce);
    }
}
