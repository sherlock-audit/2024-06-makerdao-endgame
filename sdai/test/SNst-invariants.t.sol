// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2024 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.8.21;

import "dss-test/DssTest.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { VatAbstract, PotAbstract, ChainlogAbstract } from "dss-interfaces/Interfaces.sol";
import { NstMock } from "test/mocks/NstMock.sol";
import { NstJoinMock } from "test/mocks/NstJoinMock.sol";
import { SNst } from "src/SNst.sol";

contract SNstHandler is StdUtils, StdCheats {
    Vm      public vm;
    SNst    public token;
    NstMock public nst;
    address public snstOwner;
    mapping(bytes32 => uint256) public numCalls;

    uint256 constant RAY = 10 ** 27;

    constructor(
        Vm      vm_,
        address token_,
        address nst_,
        address snstOwner_
    ) {
        vm    = vm_;
        token = SNst(token_);
        nst   = NstMock(nst_);
        snstOwner = snstOwner_;
    }

    function setNsr(uint256 nsr) external {
        numCalls["setNsr"]++;
        nsr = bound(nsr, RAY, 1000000021979553151239153027); // between 0% and 100% apy
        vm.prank(snstOwner); token.file("nsr", nsr);
    }

    function warp(uint256 secs) external {
        numCalls["warp"]++;
        secs = bound(secs, 0, 365 days);
        vm.warp(block.timestamp + secs);
    }

    function drip() external {
        numCalls["drip"]++;
        token.drip();
    }

    function deposit(uint256 assets) external {
        numCalls["deposit"]++;
        deal(address(nst), address(this), assets);
        nst.approve(address(token), assets);
        token.deposit(assets, address(this));
    }

    function mint(uint256 shares) external {
        numCalls["mint"]++;
        deal(address(nst), address(this), token.previewMint(shares));
        nst.approve(address(token), token.previewMint(shares));
        token.mint(shares, address(this));
    }

    function withdraw(uint256 assets) external {
        numCalls["withdraw"]++;
        assets = bound(assets, 0, token.previewWithdraw(token.balanceOf(address(this))));
        token.withdraw(assets, address(this), address(this));
    }

    function withdrawAll() external {
        numCalls["withdrawAll"]++;
        token.withdraw(token.previewWithdraw(token.balanceOf(address(this))), address(this), address(this));
    }

    function redeem(uint256 shares) external {
        numCalls["redeem"]++;
        shares = bound(shares, 0, token.balanceOf(address(this)));
        token.redeem(shares, address(this), address(this));
    }

    function redeemAll() external {
        numCalls["redeemAll"]++;
        token.redeem(token.balanceOf(address(this)), address(this), address(this));
    }
}

contract SNstInvariantsTest is DssTest {
    VatAbstract vat;
    NstJoinMock nstJoin;
    NstMock     nst;
    PotAbstract pot;
    SNst        token;
    SNstHandler handler;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));

        ChainlogAbstract chainlog = ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
        
        vat = VatAbstract(chainlog.getAddress("MCD_VAT"));
        nst = new NstMock();
        nstJoin = new NstJoinMock(address(vat), address(nst));
        nst.rely(address(nstJoin));

        token = SNst(address(new ERC1967Proxy(address(new SNst(address(nstJoin), address(123))), abi.encodeCall(SNst.initialize, ()))));

        vm.prank(chainlog.getAddress("MCD_PAUSE_PROXY")); vat.rely(address(token));

        handler = new SNstHandler(vm, address(token), address(nst), address(this));

         // uncomment and fill to only call specific functions
        bytes4[] memory selectors = new bytes4[](9);
        selectors[0] = SNstHandler.setNsr.selector;
        selectors[1] = SNstHandler.warp.selector;
        selectors[2] = SNstHandler.drip.selector;
        selectors[3] = SNstHandler.deposit.selector;
        selectors[4] = SNstHandler.mint.selector;
        selectors[5] = SNstHandler.withdraw.selector;
        selectors[6] = SNstHandler.withdrawAll.selector;
        selectors[7] = SNstHandler.redeem.selector;
        selectors[8] = SNstHandler.redeemAll.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));

        targetContract(address(handler)); // invariant tests should fuzz only handler functions
    }

    function invariant_nst_balance_vs_redeemable() external view {
        // for only setNsr, warp, drip
        // assertEq(nst.balanceOf(address(token)), token.totalSupply() * token.chi() / RAY);

        // for everything
        assertGe(nst.balanceOf(address(token)), token.totalSupply() * token.chi() / RAY);
    }

    function invariant_call_summary() private view { // make external to enable
        console.log("------------------");

        console.log("\nCall Summary\n");
        console.log("setNsr", handler.numCalls("setNsr"));
        console.log("warp", handler.numCalls("warp"));
        console.log("drip", handler.numCalls("drip"));
        console.log("deposit", handler.numCalls("deposit"));
        console.log("mint", handler.numCalls("mint"));
        console.log("withdraw", handler.numCalls("withdraw"));
        console.log("withdrawAll", handler.numCalls("withdrawAll"));
        console.log("redeem", handler.numCalls("redeem"));
        console.log("redeemAll", handler.numCalls("redeemAll"));
    }
}
