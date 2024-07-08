// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2021 Dai Foundation
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

import "erc4626-tests/ERC4626.test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { VatMock } from "test/mocks/VatMock.sol";
import { NstMock } from "test/mocks/NstMock.sol";
import { NstJoinMock } from "test/mocks/NstJoinMock.sol";

import { SNst } from "src/SNst.sol";

contract SNstERC4626Test is ERC4626Test {

    using stdStorage for StdStorage;

    VatMock vat;
    NstMock nst;
    NstJoinMock nstJoin;

    SNst sNst;

    uint256 constant private RAY = 10**27;

    function setUp() public override {
        vat = new VatMock();
        nst = new NstMock();
        nstJoin = new NstJoinMock(address(vat), address(nst));

        nst.rely(address(nstJoin));
        vat.suck(address(123), address(nstJoin), 100_000_000_000 * 10 ** 45);

        sNst = SNst(address(new ERC1967Proxy(address(new SNst(address(nstJoin), address(0))), abi.encodeCall(SNst.initialize, ()))));
        vat.rely(address(sNst));

        sNst.file("nsr", 1000000001547125957863212448);

        vat.hope(address(nstJoin));

        vm.warp(100 days);
        sNst.drip();

        assertGt(sNst.chi(), RAY);

        _underlying_ = address(nst);
        _vault_ = address(sNst);
        _delta_ = 0;
        _vaultMayBeEmpty = true;
        _unlimitedAmount = false;
    }

    // setup initial vault state
    function setUpVault(Init memory init) public override {
        for (uint256 i = 0; i < N; i++) {
            init.share[i] %= 1_000_000_000 ether;
            init.asset[i] %= 1_000_000_000 ether;
            vm.assume(init.user[i] != address(0) && init.user[i] != address(sNst));
        }
        super.setUpVault(init);
    }

    // setup initial yield
    function setUpYield(Init memory init) public override {
        vm.assume(init.yield >= 0);
        init.yield %= 1_000_000_000 ether;
        uint256 gain = uint256(init.yield);

        uint256 supply = sNst.totalSupply();
        if (supply > 0) {
            uint256 nChi = gain * RAY / supply + sNst.chi();
            uint256 chiRho = (block.timestamp << 192) + nChi;
            vm.store(
                address(sNst),
                bytes32(uint256(5)),
                bytes32(chiRho)
            );
            assertEq(uint256(sNst.chi()), nChi);
            assertEq(uint256(sNst.rho()), block.timestamp);
            vat.suck(address(sNst.vow()), address(this), gain * RAY);
            nstJoin.exit(address(sNst), gain);
        }
    }

}
