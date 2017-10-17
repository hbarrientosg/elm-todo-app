require("./app.css");
require("./routing");
require("./components/todoEntry");
require("./components/todo");

const App = require("./App");

App.Main.embed(document.getElementById("app"));
