# carpETHii
BETH 2019 - carpETHii submission

CarpETHii

Goal

How can WWF incentivize local communities in Carpathian Mountains to cooperate with the environmental project, act honestly and improve the quality of the whole ecosystem?

Main requirements

    • Funding from stakeholders flows into WWF led projects and local community projects
    • Local community projects get selected/prioritized by the community
    • The funds for local projects should depend on the health of the ecosystem
    • Main tasks are defined by the stakeholders that need to be done
    • Community members can propose and complete minor tasks to help the ecosystem

Solution
    • Use Ethereum based private blockchain installed on the WWF compute nodes distributed across their offices
        ◦ Use Proof of Stake implementation to save computational power (since all nodes are controlled by WWF)
    • Following Smart Contracts are deployed in the Ethereum Blockchain
        ◦ mainState (mainState.sol) – where the main logic is implemented
            ▪ Users of the system are created and stored in this contract – stakeholders and community members
            ▪ This contract distributes own Tokens to Stakeholders and Community members
            ▪ Task list is stored and tracked in this contract
            ▪ Ecosystem performance function is computed here with input from:
                • Subjective voting of stakeholders
                • Input from ecosystem IoT sensors
                • Tasks successfully completed by the community members
        ◦ projectVoting (projectVoting.sol) – this contract stores local community projects with their ranking and status
        ◦ CarpETHii Community Token (CETHc.sol) – a.k.a. voting token - private token that gets distributed to the community members and can be used for voting
        ◦ CarpETHii Investor Token (CETHi.sol) – a.k.a decision token - private token distributed to the investors that represent their stake in the system, it can also provide weight to the performance indicators
        ◦ EuroWWFcoin (wwefc.sol) – a.k.a finance token - private (non-volatile) token distributed to the community members that can be exchanged for the same amount of money at the WWF
    • Stakeholders can donate money to the system and receive tokens representing their stake
        ◦ The token received is “CarpETHii Investor Token”
        ◦ Stakeholders receive tokens only by donating more than certain amount of money
        ◦ Stakeholders can interact with the mainState smart contract using their Ethereum address and give subjective vote about the performance of the ecosystem
        ◦ The number of tokens give them power when judging the performance of the ecosystem
    • Donated money (off-chain) is tracked as a number in the mainState smart contract for the bookkeeping, all the expenses are tracked here
        ◦ This donated money will be released to the community tokens based on the performance of the system in particular time intervals
    • IOT Sensors – sensor measure performance of the ecosystem and provide aggregated input to the main performance function in the mainState contract
        ◦ Sensors should use Oracle to aggregate their output and translate the output in a summarized way
        ◦ Sensors will also determine the outcome of a specific task if this is feasible
        ◦ Sensor data are not stored on the Blockchain, only the aggregated results
    • Local community projects – these projects are financed by part of the stakeholders’ investments 
        ◦ The amount of funds these projects receive is dependent on the performance of the ecosystem
        ◦ Local community proposes these projects off-chain during regular get-togethers
        ◦ The voting for projects is done by sending private voting tokens (CETHc) to the smart contract projectVoting, providing the name of the project that should get the tokens
        ◦ List of the projects is implemented as a mapping in Solidity
        ◦ The project with the most tokens will get implemented in specific time intervals
    • Tasks for the local community – these tasks are open for completion
        ◦ Tasks are defined either by the stakeholders (these tasks get higher weight – higher reward)
        ◦ Local community can also define tasks themselves during regular get-togethers
        ◦ Tasks need to be claimed by community members if they are unclaimed yet
        ◦ Tasks can either be completed automatically by using an IOT sensor or they need to be claimed as completed by the task assignee
        ◦ Task assignee can upload data related to the task completion to the system (GPS data, pictures). This data is not stored on the blockchain but in a dedicated database.
        ◦ When task is marked as completed by the assignee, then the community needs to vote about the outcome of the task
        ◦ If task is completed (automatically or it was voted completed), the task assignee gets voting tokens and finance tokens
        ◦ Any completed task improves the performance of the ecosystem
