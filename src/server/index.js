import path from "path";
import express from "express";
import graphqlHTTP from "express-graphql";
import schema from "./schema";
import db from "./db";

const webpackMiddleware = require("webpack-dev-middleware");
const webpackHotMiddleware = require("webpack-hot-middleware");
const webpack = require("webpack");
const config = require("../../webpack.config");

const isDev = process.env.NODE_ENV !== "production";
const port = isDev ? 8555 : process.env.PORT;
const app = express();

app.use("/api/graphql", graphqlHTTP({
  schema: schema,
  rootValue: db,
  graphiql: true
}));

if (isDev) {
  const compiler = webpack(config);
  const middleware = webpackMiddleware(compiler, {
    publicPath: config.output.publicPath,
    contentBase: "src/app",
    stats: {
      colors: true,
      hash: false,
      timings: true,
      chunks: false,
      chunkModules: false,
      modules: false
    }
  });
  app.use(middleware);
  app.use(webpackHotMiddleware(compiler));
  app.get("/", function response(req, res) {
    console.log(req, res);
    res.write(
      middleware.fileSystem.readFileSync(
        path.join(__dirname, "/app/index.html")
      )
    );
    res.end();
  });
} else {
  app.use(express.static(__dirname + "/build"));
  app.get("*", function response(req, res) {
    res.sendFile(path.join(__dirname, "/build/index.html"));
  });
}

app.listen(port, err => {
  if (err) {
    console.warn(err);
  }
  console.info(
    `==> 🌎 Listening on port ${port}. Open up http://0.0.0.0:${port}/ in your browser.`
  );
});
