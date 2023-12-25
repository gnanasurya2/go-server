const fs = require("fs");

let total = 0,
  number_of_requests = 0,
  min = Number.MAX_SAFE_INTEGER,
  max = 0,
  latency_map = {},
  latency_arr = [];

const getTrees = async () => {
  const data = fs.readFileSync(
    "./results_nested_set_model_with_parent_id.json"
  );
  const parsed = Object.keys(JSON.parse(data).latency_map);
  console.log(parsed);

  for (let i = 0; i < parsed.length; i++) {
    const options = {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    };

    const start = Date.now();
    const data = await fetch(
      `http://127.0.0.1:3000/employee/get-employee-tree?name=${parsed[i]}`,
      options
    );
    const latency = Date.now() - start;
    total += latency;
    latency_map[parsed[i]] = latency;
    latency_arr.push(latency);
    number_of_requests++;
    min = Math.min(min, latency);
    max = Math.max(max, latency);
    console.log(`${parsed[i]} - ${latency}`);
  }
};

const main = async () => {
  await getTrees();
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
    "get_trees_nested_set_model_with_children_parent_id.json",
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
