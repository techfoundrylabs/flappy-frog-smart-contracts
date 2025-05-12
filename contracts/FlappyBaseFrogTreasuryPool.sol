// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlappyBaseFrogTreasuryPool is Ownable {
    address payable teamAddress;

    event DepositReceived(
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );
    event TeamAddressUpdated(
        address indexed oldAddress,
        address indexed newAddress,
        uint256 timestamp
    );

    event PayWinner(address indexed to, uint256 amount, uint256 timestamp);

    constructor() Ownable(msg.sender) {
        teamAddress = payable(msg.sender);
    }

    function deposit() external payable {
        _deposit();
    }

    function _deposit() internal {
        require(msg.value > 0, "Value must have major of 0");
        uint256 amount = calculateAmount(msg.value);
        teamAddress.transfer(amount);
        emit DepositReceived(msg.sender, msg.value, block.timestamp);
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

    function calculateAmount(uint256 _amount) private pure returns (uint256) {
        return ((_amount * 40) / 100);
    }

    function getTreasuryBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function payWinner(address payable winner) external onlyOwner {
        uint256 treasury = (address(this).balance);
        winner.transfer(treasury);
        emit PayWinner(winner, treasury, block.timestamp);
    }

    receive() external payable {
        teamAddress.transfer(msg.value);
    }

    fallback() external payable {
        teamAddress.transfer(msg.value);
    }
}
