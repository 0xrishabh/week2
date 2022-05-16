pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    var i=2**n;
    var level = 0;
    component hash[n][i/2];
    for(var j=0; j<n;j++){
        for(var k=0; k<(i/2);k++){
            hash[j][k] = Poseidon(2);
        }
    }

    while(level<n){
        var k=0;
        // setting up the leaves
        if(level == 0){
            for (var j=0; j<i; j=j+2){
                hash[level][k].inputs[0] <== leaves[j];
                hash[level][k].inputs[1] <== leaves[j+1];
                k++;
            }
        } else {
            // this is for all the other levels, basically recursion in a way by `level-1`
            for (var j=0;j<i; j=j+2){
                hash[level][k].inputs[0] <== hash[level-1][j].out;
                hash[level][k].inputs[1] <== hash[level-1][j+1].out;
                k++;
            }            
            
        }
        level++;                
        i = i/2;
    }
    root <== hash[n-1][0].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    for (var i=0; i<n; i++) {
        poseidon[i] = Poseidon(2);
        if (i==0) {
            poseidon[i].inputs[0] <== leaf;
            poseidon[i].inputs[1] <== path_elements[i];
        } else {
            poseidon[i].inputs[0] <== poseidon[i-1].out + (path_elements[i]-poseidon[i-1].out)*path_index[i];
            poseidon[i].inputs[1] <== path_elements[i] - (path_elements[i]-poseidon[i-1].out)*path_index[i];
        }
    }
    root <== poseidon[n-1].out;
}