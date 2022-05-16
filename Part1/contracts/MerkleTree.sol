//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves

        hashes = new uint256[](15);

    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;

        // second layer
        uint Poseidonout = 8;
        for (uint i=0; i<8; i=i+2){
            hashes[Poseidonout] = PoseidonT3.poseidon([hashes[i], hashes[i+1]]);
            Poseidonout++;
        }

        // third layer
        Poseidonout = 12;
        for (uint i=8; i<12; i=i+2){
            hashes[Poseidonout] = PoseidonT3.poseidon([hashes[i], hashes[i+1]]);
            Poseidonout++;
        }
        // top node
        hashes[14] = PoseidonT3.poseidon([hashes[12], hashes[13]]);

        root = hashes[14];
        index++;
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
            return verifyProof(a, b, c, input);

        // [assignment] verify an inclusion proof and check that the proof root matches current root
    }
}
