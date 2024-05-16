# Foundry Basics

### HelperConfig

Contract depends depends on a chainlink price feed and requires it's contract address to be passed in the constructor when deployed.

Helper config us used in our deploy script provides the the real Chainlink interface if we're deploying to sepoloa and our mock if we're working locally.

### MockV3Aggregator

Used when running tests locally.
