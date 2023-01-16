// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

/**
    스테이킹 수량 => 컨텐츠의 사이즈 결정 (상대적으로? or 고정된 3가지 타입만 우선 지원한다?)
    스테이킹 시점 => 컨텐츠의 노출 순서 결정
    스테이킹 기간 => 컨텐츠의 유효 기간 결정
    스테이킹 수량에 비례해서 표시되는 컨텐츠의 사이즈가 달라짐. 사이즈도 내부적으로 결정?
    컨텐츠들을 뱉어내는 view 함수는 어떻게 구성하는게 좋을까? 모든 contents array를 다 뱉어내는게 좋을까? (유효한 contents만 뱉어내야 할듯)
 */

struct Yell {
    string contents;
    uint256 amount;
    uint256 createdAt;
    uint256 validUntil;
    bool withdrawn;
}

contract Protocol {
    mapping(address => Yell[]) public yells;

    event Yelled(address indexed user, string contents, uint256 amount, uint256 createdAt, uint256 validUntil);
    event Withdrawn(address indexed user, uint256 amount);

    function yell(string calldata contents_, uint256 validUntil_) public payable {
        require(msg.value > 0, "You need to pay to yell");
    }

    
    function withdraw() public {
        for (uint256 i = 0; i < yells[msg.sender].length; i++) {
            if (yells[msg.sender][i].validUntil < block.timestamp) {
                withdraw(i);
            }
        }
    }

    // TODO: should be nonreentrant
    function _withdraw(uint256 index) private {
        require(!yells[msg.sender][index].withdrawn, "Already withdrawn");
        yells[msg.sender][index].withdrawn = true;
        uint256 amount = yells[msg.sender][index].amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getContents() public view returns (Yell[] memory) {

    }
}