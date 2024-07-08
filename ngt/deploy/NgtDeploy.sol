// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
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

import { ScriptTools } from "dss-test/ScriptTools.sol";

import { Ngt } from "src/Ngt.sol";
import { MkrNgt } from "src/MkrNgt.sol";

import { NgtInstance } from "./NgtInstance.sol";

library NgtDeploy {
    function deploy(
        address deployer,
        address owner,
        address mkr,
        uint256 rate
    ) internal returns (NgtInstance memory instance) {
        address _ngt = address(new Ngt());
        ScriptTools.switchOwner(_ngt, deployer, owner);

        address _mkrNgt = address(new MkrNgt(mkr, _ngt, rate));

        instance.ngt    = _ngt;
        instance.mkrNgt = _mkrNgt;
    }
}
