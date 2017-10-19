require("./app.css");
require("./favicon.ico");

require("./routing");
require("./components/todoEntry");
require("./components/todo");


const App = require("./App");
App.Main.embed(document.getElementById("app"));
