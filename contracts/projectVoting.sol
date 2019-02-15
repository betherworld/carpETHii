pragma solidity ^0.5.0;

/*
Smart Contract for voting for community projects.
Community members should send their Voting tokens together with the ID of the project and these tokens will be
added to the mapping element with all the projects
*/

import "./CETHc.sol";

contract projectVoting {
    address admin;
    CETHcToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    string[] public projects;

    struct CommunityProject {
        uint votes;
        bool _isImplemented;
    }

    //mapping (string => uint) public voteStatus;
    mapping (string => CommunityProject) communityProjects;

    constructor(CETHcToken _tokenContract) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
    }

    function addProject(string memory _newProject) public {
        require(msg.sender == admin);
        projects.push(_newProject);
        communityProjects[_newProject].votes = 0;
        communityProjects[_newProject]._isImplemented = false;
    }

    function implementProject(string memory project) public {
        require(msg.sender == admin);
        communityProjects[project]._isImplemented = true;      
    }


    function voteProject(string memory _projectName) public {
        //require(tokenContract.allowance(msg.sender, address(this)) > 0);
        uint tokenAmount = tokenContract.allowance(msg.sender, address(this));
        require(tokenContract.transferFrom(msg.sender, address(this), tokenAmount));
        communityProjects[_projectName].votes += tokenAmount;
    }
}
