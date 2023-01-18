// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/**
    스테이킹 수량 => 컨텐츠의 사이즈 결정 (상대적으로? or 고정된 3가지 타입만 우선 지원한다?)
    스테이킹 시점 => 컨텐츠의 노출 순서 결정
    스테이킹 기간 => 컨텐츠의 유효 기간 결정
    스테이킹 수량에 비례해서 표시되는 컨텐츠의 사이즈가 달라짐. 사이즈도 내부적으로 결정?
    컨텐츠들을 뱉어내는 view 함수는 어떻게 구성하는게 좋을까? 모든 contents array를 다 뱉어내는게 좋을까? (유효한 contents만 뱉어내야 할듯)
    어떻게 하면 컨텐츠들을 효율적으로 저장할 수 있을까? (이게 가장 중요) 그리고 어떻게 하면 효율적으로 수 많은 컨텐츠들을 클라이언트에 뿌려줄 수 있을까?
    withdraw를 하면 해당 컨텐츠는 스토리지에서 삭제해서 gas fee를 saving하는게 좋을듯
 */

struct Yell {
    string contents;
    address owner;
    uint256 amount;
    uint256 createdAt;
    uint256 validUntil;
}

contract Protocol is ReentrancyGuard {
    Yell[] public yells;
    mapping(address => uint256[]) public indexes;

    event Yelled(address indexed user, string contents, uint256 amount, uint256 createdAt, uint256 validUntil);
    event Withdrawn(address indexed user, uint256 amount);

    function yell(string calldata contents_, uint256 validUntil_) public payable {
        require(contents_ != "", "Protocol: contents cannot be empty");
        require(validUntil_ > block.timestamp, "Protocol: validUntil must be greater than current timestamp");
        require(msg.value > 0, "Protocol: need to stake ETH to yell");

        yells.push(Yell(contents_, msg.sender, msg.value, block.timestamp, validUntil_, false));
        indexes[msg.sender].push(yells.length - 1);

        emit Yelled(msg.sender, contents_, msg.value, block.timestamp, validUntil_);
    }

    
    function withdraw() public {
        for (uint256 i = 0; i < indexes[msg.sender].length; i++) {
            uint256 index = indexes[msg.sender][i];
            if (yells[index].validUntil < block.timestamp) {
                withdraw(index);
            }
        }
    }

    function _withdraw(uint256 index) private nonReentrant{
        // content will be reset to empty string after withdrawal
        require(yells[index].contents != "", "Protocol: already withdrawn");
        require(yells[index].owner == msg.sender, "Protocol: not authorized");

        uint256 amount = yells[index].amount;

        // delete yell content for gas saving
        delete yells[index];
        
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getContents() public view returns (Yell[] memory) {

    }

    function getMyContents() public view returns (Yell[] memory) {

    }
}