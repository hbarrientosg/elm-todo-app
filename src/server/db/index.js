const knex = require("knex");

const db = knex({
  client: "sqlite3",
  connection: {
    filename: "./db.sqlite"
  }
});

const Todos = [];

const root = {
  todos: () => Todos
}


export default root;
