const nodeResolve = require("rollup-plugin-node-resolve");
const commonjs = require("rollup-plugin-commonjs");

export default {
  input: "www/tmp/index.js",
  output: {
    file: "www/FCMPlugin.js",
    format: "iife",
    name: "FCMPlugin",
    globals: {}
  },
  plugins: [
    commonjs({
      include: "node_modules/**"
    }),
    nodeResolve({ browser: true })
  ],
  external: ["rxjs"]
};
