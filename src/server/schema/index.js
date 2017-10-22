const path = require("path");
const fs = require("fs");
const graphql = require("graphql");

const schemaString = [fs.readFileSync(path.join(__dirname, "./schema.graphql"), "utf8")]

const Schema = graphql.buildSchema(schemaString[0]);

export default Schema;
