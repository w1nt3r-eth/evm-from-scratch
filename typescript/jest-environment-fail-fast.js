const ParentEnvironment = require("jest-environment-node").default;

// This is a custom Jest environment that skips the remaining tests when a test fails.
// It's used to focus on a single test at a time

class JestEnvironmentFailFast extends ParentEnvironment {
  failedTest = false;

  async handleTestEvent(event, state) {
    if (event.name === "hook_failure" || event.name === "test_fn_failure") {
      this.failedTest = true;
      showFailedTestOnExit(event);
    } else if (this.failedTest && event.name === "test_start") {
      event.test.mode = "todo";
    }

    if (super.handleTestEvent) {
      await super.handleTestEvent(event, state);
    }
  }
}

function showFailedTestOnExit(event) {
  // setTimeout is used to output text after Jest's default reporter has finished
  // printing the test failure message. Otherwise, Jest could print over our text.
  setTimeout(() => {
    const t = require("../evm.json").find((t) => t.name === event.test.name);
    process.stdout.write(
      `\n\nFailing test case (${event.test.name}):\n\n` +
        (t.code.asm
          ? t.code.asm
              .split("\n")
              .map((s) => "  " + s)
              .join("\n")
          : t.code.bin) +
        "\n\n"
    );
  });
}

module.exports = JestEnvironmentFailFast;
