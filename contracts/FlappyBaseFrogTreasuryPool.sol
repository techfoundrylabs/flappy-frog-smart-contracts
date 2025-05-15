// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlappyBaseFrogTreasuryPool is Ownable {
    address payable teamAddress;
    uint256 teamEarn = 40;

    event DepositReceived(
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    event GiftReceived(address indexed from, uint256 amount, uint256 timestamp);

    event TeamAddressUpdated(
        address indexed oldAddress,
        address indexed newAddress,
        uint256 timestamp
    );

    event TeamEarnUpdated(uint256 oldEarn, uint256 newEarn, uint256 timestamp);

    event PayWinner(address indexed to, uint256 amount, uint256 timestamp);

    constructor() Ownable(msg.sender) {
        teamAddress = payable(msg.sender);
    }

    function deposit() external payable {
        require(msg.value > 0, "Value must have major of 0");
        uint256 amount = calculateAmount(msg.value);
        teamAddress.transfer(amount);
        emit DepositReceived(msg.sender, msg.value, block.timestamp);
    }

    function gift(uint256 amount) private {
        require(amount > 0, "Gift amount must be greater than 0");
        (bool success, ) = teamAddress.call{value: amount}("");
        require(success, "Gift payment failed");
        emit GiftReceived(msg.sender, amount, block.timestamp);
    }

    function setTeamEarn(uint256 _teamEarn) external onlyOwner {
        require(_teamEarn <= 100, "Cannot exceed 100%");
        uint256 oldEarn = teamEarn;
        teamEarn = _teamEarn;
        emit TeamEarnUpdated(oldEarn, _teamEarn, block.timestamp);
    }

    function updateTeamAddress(
        address payable _newTeamAddress
    ) external onlyOwner {
        address oldTeamAddress = teamAddress;
        teamAddress = _newTeamAddress;
        emit TeamAddressUpdated(
            oldTeamAddress,
            _newTeamAddress,
            block.timestamp
        );
    }

    function calculateAmount(uint256 _amount) private view returns (uint256) {
        return ((_amount * teamEarn) / 100);
    }

    function getTreasuryBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function payWinner(address payable winner) external onlyOwner {
        uint256 treasury = (address(this).balance);
        (bool success, ) = winner.call{value: treasury}("");
        if (!success) {
            emit PayWinner(winner, 0, block.timestamp); // Log fallito
            revert("Payment to winner failed");
        }
        emit PayWinner(winner, treasury, block.timestamp);
    }

    receive() external payable {
        gift(msg.value);
    }

    fallback() external payable {
        gift(msg.value);
    }
}
