// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {IERCServiceObject} from "../interfaces/IERCServiceObject.sol";
import {IERCServiceObjectController} from "../interfaces/IERCServiceObjectController.sol";
import {TokenizedAutonomousService} from "../src/TokenizedAutonomousService.sol";

contract TokenizedAutonomousServiceTest is Test {
    TokenizedAutonomousService internal service;

    address internal owner = address(0xA11CE);
    address internal buyer = address(0xB0B);
    address internal payer = address(0xCAFE);
    address internal revenue = address(0xFEE);
    address internal serviceAccount = address(0x6551);
    uint256 internal operatorKey = 0xA0B0C0;
    address internal operator;

    bytes32 internal manifestHash = keccak256("service-manifest");
    bytes32 internal paymentManifestHash = keccak256("payment-manifest");

    function setUp() public {
        operator = vm.addr(operatorKey);
        service = new TokenizedAutonomousService();
    }

    function testSupportsServiceInterfaces() public view {
        assertTrue(service.supportsInterface(type(IERCServiceObject).interfaceId));
        assertTrue(service.supportsInterface(type(IERCServiceObjectController).interfaceId));
        assertTrue(service.supportsInterface(0x80ac58cd));
    }

    function testMintInitializesService() public {
        uint256 serviceId = _mint();

        assertEq(service.ownerOf(serviceId), owner);
        assertEq(service.tokenURI(serviceId), "ipfs://service");
        assertEq(service.serviceRevenueRecipient(serviceId), owner);

        (string memory uri, bytes32 storedManifestHash) = service.serviceManifest(serviceId);
        assertEq(uri, "ipfs://service");
        assertEq(storedManifestHash, manifestHash);

        (string memory paymentURI, bytes32 storedPaymentHash, uint64 routeNonce) =
            service.servicePaymentManifest(serviceId);
        assertEq(paymentURI, "ipfs://payment");
        assertEq(storedPaymentHash, paymentManifestHash);
        assertEq(routeNonce, 1);
    }

    function testOwnerAndOperatorPermissions() public {
        uint256 serviceId = _mint();

        vm.prank(owner);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));

        vm.prank(operator);
        service.setServiceManifest(serviceId, "ipfs://service-v2", keccak256("service-v2"));

        (string memory uri, bytes32 storedManifestHash) = service.serviceManifest(serviceId);
        assertEq(uri, "ipfs://service-v2");
        assertEq(storedManifestHash, keccak256("service-v2"));

        vm.prank(operator);
        vm.expectRevert(TokenizedAutonomousService.NotServiceOwner.selector);
        service.setServicePaymentManifest(serviceId, "ipfs://payment-v2", keccak256("payment-v2"));
    }

    function testRevenueAndPaymentManifestIncrementRouteNonce() public {
        uint256 serviceId = _mint();

        vm.prank(owner);
        service.setServiceRevenueRecipient(serviceId, revenue);

        assertEq(service.serviceRevenueRecipient(serviceId), revenue);
        (,, uint64 routeNonce) = service.servicePaymentManifest(serviceId);
        assertEq(routeNonce, 2);

        vm.prank(owner);
        service.setServicePaymentManifest(serviceId, "ipfs://payment-v2", keccak256("payment-v2"));

        (string memory paymentURI, bytes32 storedPaymentHash, uint64 updatedNonce) =
            service.servicePaymentManifest(serviceId);
        assertEq(paymentURI, "ipfs://payment-v2");
        assertEq(storedPaymentHash, keccak256("payment-v2"));
        assertEq(updatedNonce, 3);
    }

    function testTransferResetsOperationalRights() public {
        uint256 serviceId = _mint();

        vm.startPrank(owner);
        service.setServiceAccount(serviceId, serviceAccount);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));
        service.setServiceReceiptIssuer(serviceId, address(0x1234), true);
        service.transferFrom(owner, buyer, serviceId);
        vm.stopPrank();

        assertEq(service.serviceAccount(serviceId), address(0));
        (address storedOperator, uint64 expiresAt) = service.serviceOperator(serviceId);
        assertEq(storedOperator, address(0));
        assertEq(expiresAt, 0);
        assertEq(service.serviceRevenueRecipient(serviceId), buyer);

        (string memory paymentURI, bytes32 storedPaymentHash, uint64 routeNonce) =
            service.servicePaymentManifest(serviceId);
        assertEq(paymentURI, "");
        assertEq(storedPaymentHash, bytes32(0));
        assertEq(routeNonce, 2);
        assertFalse(service.isAuthorizedReceiptIssuer(serviceId, address(0x1234)));
    }

    function testVerifiesAndAnchorsServiceReceipt() public {
        uint256 serviceId = _mint();

        vm.prank(owner);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));

        IERCServiceObject.ServiceReceipt memory receipt = IERCServiceObject.ServiceReceipt({
            serviceContract: address(service),
            serviceId: serviceId,
            payer: payer,
            issuer: operator,
            revenueRecipient: owner,
            requestHash: keccak256("request"),
            responseHash: keccak256("response"),
            paymentHash: keccak256("x402-payment"),
            paymentManifestHash: paymentManifestHash,
            receiptURIHash: keccak256(bytes("ipfs://receipt")),
            routeNonce: 1,
            issuerEpoch: 2,
            issuedAt: uint64(block.timestamp)
        });

        bytes memory signature = _signReceipt(receipt);
        assertTrue(service.verifyServiceReceipt(receipt, signature));

        bytes32 receiptHash = service.anchorServiceReceipt(receipt, signature, "ipfs://receipt");
        assertTrue(service.isReceiptAnchored(serviceId, receiptHash));

        vm.expectRevert(TokenizedAutonomousService.DuplicateReceipt.selector);
        service.anchorServiceReceipt(receipt, signature, "ipfs://receipt");
    }

    function testReceiptInvalidAfterRouteChange() public {
        uint256 serviceId = _mint();

        vm.prank(owner);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));

        IERCServiceObject.ServiceReceipt memory receipt = IERCServiceObject.ServiceReceipt({
            serviceContract: address(service),
            serviceId: serviceId,
            payer: payer,
            issuer: operator,
            revenueRecipient: owner,
            requestHash: keccak256("request"),
            responseHash: keccak256("response"),
            paymentHash: keccak256("x402-payment"),
            paymentManifestHash: paymentManifestHash,
            receiptURIHash: keccak256(bytes("ipfs://receipt")),
            routeNonce: 1,
            issuerEpoch: 2,
            issuedAt: uint64(block.timestamp)
        });

        bytes memory signature = _signReceipt(receipt);

        vm.prank(owner);
        service.setServiceRevenueRecipient(serviceId, revenue);

        assertFalse(service.verifyServiceReceipt(receipt, signature));
    }

    function testReceiptURIIsSigned() public {
        uint256 serviceId = _mint();

        vm.prank(owner);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));

        IERCServiceObject.ServiceReceipt memory receipt = IERCServiceObject.ServiceReceipt({
            serviceContract: address(service),
            serviceId: serviceId,
            payer: payer,
            issuer: operator,
            revenueRecipient: owner,
            requestHash: keccak256("request"),
            responseHash: keccak256("response"),
            paymentHash: keccak256("x402-payment"),
            paymentManifestHash: paymentManifestHash,
            receiptURIHash: keccak256(bytes("ipfs://receipt")),
            routeNonce: 1,
            issuerEpoch: 2,
            issuedAt: uint64(block.timestamp)
        });

        bytes memory signature = _signReceipt(receipt);

        vm.expectRevert(TokenizedAutonomousService.InvalidReceipt.selector);
        service.anchorServiceReceipt(receipt, signature, "ipfs://spoofed");
    }

    function testReceiptInvalidAfterOperatorReapproval() public {
        uint256 serviceId = _mint();

        vm.prank(owner);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));

        IERCServiceObject.ServiceReceipt memory receipt = IERCServiceObject.ServiceReceipt({
            serviceContract: address(service),
            serviceId: serviceId,
            payer: payer,
            issuer: operator,
            revenueRecipient: owner,
            requestHash: keccak256("request"),
            responseHash: keccak256("response"),
            paymentHash: keccak256("x402-payment"),
            paymentManifestHash: paymentManifestHash,
            receiptURIHash: keccak256(bytes("ipfs://receipt")),
            routeNonce: 1,
            issuerEpoch: 2,
            issuedAt: uint64(block.timestamp)
        });

        bytes memory signature = _signReceipt(receipt);

        vm.startPrank(owner);
        service.setServiceOperator(serviceId, address(0), 0);
        service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 1 days));
        vm.stopPrank();

        assertFalse(service.verifyServiceReceipt(receipt, signature));
    }

    function _mint() internal returns (uint256 serviceId) {
        serviceId = service.mintService(owner, "ipfs://service", manifestHash, "ipfs://payment", paymentManifestHash);
    }

    function _signReceipt(IERCServiceObject.ServiceReceipt memory receipt) internal view returns (bytes memory) {
        bytes32 digest = service.hashServiceReceipt(receipt);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operatorKey, digest);
        return abi.encodePacked(r, s, v);
    }
}
