const { stopDb } = require("./db");

module.exports = async () => {
  await stopDb();
};
