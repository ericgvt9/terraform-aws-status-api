const { startDb } = require("./db");

module.exports = async () => {
  await startDb();
};
