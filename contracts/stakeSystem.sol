// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract stakeSystem is ERC20 {
    constructor() ERC20("H5 Reward", "H5R") {}

    mapping(address => bool) internal contractTokenExist;
    mapping(address => bool) internal userExist;

    address[] internal stakeHolders;
    address[] internal stakeTokens;

    // tokenContract => tokenStakers
    mapping(address => address[]) public tokenContractStakers;

    struct stakeDetails {
        uint stakeAmount;
        uint accruedReward;
        uint stakeTime;
    }

    // tokenContract => tokenStakerEOA => stakeDetails(struct)
    mapping(address => mapping(address => stakeDetails))
        public uniqueStakeDetails;

    function stakeToken(address _tokenContractAddress, uint _amount) internal {
        if (!contractTokenExist[_tokenContractAddress]) {
            _addTokenToRecord(_tokenContractAddress);
        }

        if (!userExist[msg.sender]) {
            _addUserToRecord(msg.sender);
        }

        stakeDetails storage myStakeDetail = uniqueStakeDetails[
            _tokenContractAddress
        ][msg.sender];
        if (myStakeDetail.stakeTime == 0) {
            addUserToUniqueStakeDetails(_tokenContractAddress, msg.sender);
        }

        require(
            ERC20(_tokenContractAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "TransferFrom Failed"
        );
        myStakeDetail.stakeAmount += _amount;
        myStakeDetail.stakeTime = block.timestamp;
    }

    function _addTokenToRecord(address _tokenContractAddress) internal {
        contractTokenExist[_tokenContractAddress] = true;
        stakeTokens.push(_tokenContractAddress);
    }

    function _addUserToRecord(address _userAddress) internal {
        userExist[_userAddress] = true;
        stakeHolders.push(_userAddress);
    }

    function addUserToUniqueStakeDetails(
        address _tokenContractAddress,
        address eoaAddress
    ) internal {
        tokenContractStakers[_tokenContractAddress].push(msg.sender);
    }
}
