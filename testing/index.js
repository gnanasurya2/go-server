const fs = require("fs");
class TreeNode {
  constructor(id) {
    this.id = id;
    this.children = [];
  }

  addChild(childNode) {
    this.children.push(childNode);
  }
}

function createNode(id) {
  return new TreeNode(id);
}

function addChildrenToNode(node, depth, maxChildren, nodeId = 1) {
  if (depth === 0) {
    return;
  }

  for (let i = 0; i < maxChildren; i++) {
    const childNodeId = nodeId * 10 + i + 1;
    const childNode = createNode(childNodeId);
    addChildrenToNode(
      childNode,
      depth - 1,
      Math.ceil(Math.random() * 10),
      childNodeId
    );
    node.addChild(childNode);
  }
}

function createTree(depth, maxChildren) {
  const rootNode = createNode(1);
  addChildrenToNode(rootNode, depth, maxChildren);
  return rootNode;
}

function printTree(treeNode, spaces = 0) {
  const indent = " ".repeat(spaces * 2);
  console.log(`${indent}Node ${treeNode.id}`);
  for (const child of treeNode.children) {
    printTree(child, spaces + 1);
  }
}

// Create a tree with a depth of 3 and 10 children per node
const depth = 5;
const maxChildren = 10;
// const tree = createTree(depth, maxChildren);

// // Output the tree structure
// // printTree(tree);

// fs.writeFileSync("./data.json", JSON.stringify(tree, null, 2));

const file = JSON.parse(fs.readFileSync("./data.json", "utf8"));

let total = 0,
  number_of_requests = 0,
  min = Number.MAX_SAFE_INTEGER,
  max = 0,
  latency_map = {},
  latency_arr = [];
const seedDatabase = async (children, parent_id) => {
  for (const child of children) {
    const options = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "insomnia/8.5.1",
      },
      body: JSON.stringify({
        name: child.id,
        parentId: parent_id,
      }),
    };

    const start = Date.now();
    await fetch("http://127.0.0.1:3000/employee/add-node", options);
    const latency = Date.now() - start;
    total += latency;
    latency_map[child.id] = latency;
    latency_arr.push(latency);
    number_of_requests++;
    min = Math.min(min, latency);
    max = Math.max(max, latency);
    console.log(number_of_requests);
    await seedDatabase(child.children, child.id);
  }
};

const main = async () => {
  await seedDatabase(file.children, 1);
  let p95_count = parseInt(number_of_requests * 0.95),
    p99_count = parseInt(number_of_requests * 0.95);
  let p95_sum = 0,
    p99_sum = 0;
  latency_arr.sort((a, b) => a - b);
  for (let i = p95_count; i < latency_arr.length; i++) {
    p95_sum += latency_arr[i];
    if (i >= p99_count) {
      p99_sum += latency_arr[i];
    }
  }

  fs.writeFileSync(
    "results_nested_set_model_with_parent_id.json",
    JSON.stringify({
      total,
      min,
      max,
      number_of_requests,
      avg: (total / number_of_requests).toFixed(2),
      p_95: (p95_sum / (latency_arr.length - p95_count)).toFixed(2),
      p_99: (p99_sum / (latency_arr.length - p99_count)).toFixed(2),
      latency_map,
    })
  );
  console.log({
    total,
    min,
    max,
    number_of_requests,
    avg: (total / number_of_requests).toFixed(2),
    p_95: (p95_sum / (latency_arr.length - p95_count)).toFixed(2),
    p_99: (p99_sum / (latency_arr.length - p99_count)).toFixed(2),
  });
};
main();

// { total: 6087, min: 6, max: 62, number_of_requests: 353, avg: '17.24' }
