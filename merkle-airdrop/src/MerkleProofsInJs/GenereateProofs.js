const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

// Step 1: Create 20 leaf nodes
const leaves = Array.from({ length: 200 }, (_, i) => keccak256(`Leaf ${i}`));

// Step 2: Generate the Merkle Tree
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// Step 3: Get the Merkle Root
const root = tree.getRoot().toString("hex");
console.log("Merkle Root:", root);

// Step 4: Generate a proof for a specific leaf
const leaf = keccak256("Leaf 5"); // Change this to verify other leaves
const proof = tree.getProof(leaf).map((x) => x.data.toString("hex"));
console.log("Proof for Leaf 5:", proof);

// Step 5: Verify the proof (for local testing)
const verified = tree.verify(proof, leaf, tree.getRoot());
console.log("Proof verified:", verified);
