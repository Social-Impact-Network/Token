// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts//access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./math/SafeMathInt.sol";
import "./math/SafeMathUint.sol";
import "./uniswap/IUniswapV2Router02.sol";

contract SIPilotToken is Context, AccessControl, IERC20 {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public _uniswapRouter;
    address private _daiToken = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    IERC20 public _daiInstance;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _rate;
    uint256 public _cap;
    address public _beneficiary;
    bool fundingReleased = false;

    uint256 constant private magnitude = 2**128;
    uint256 private claimableAmountPerToken;
    mapping(address => int256) private claimableAmountCorrections;
    mapping(address => uint256) private withdrawnAmounts;

    event TokensPurchased(address indexed transmitter, address indexed buyer, uint256 amountDAI, uint256 amountToken);
    event FundsReleased(address indexed beneficiary, uint256 amountDAI);
    event PaymentReceived(address indexed project_owner, uint256 amountDAI);
    event AmountPaidOut(address indexed tokenholder, uint256 amountDAI);

    constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 cap_, uint256 rate_, address beneficiary_) {
        _setupRole(MINTER_ROLE, _msgSender());
        _uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _daiInstance = IERC20(_daiToken);
        require(rate_ > 0, "rate is 0");
        require(cap_ > 0, "cap is 0");
        require(beneficiary_ != address(0), "address is null");
        _cap = cap_;
        _rate = rate_;
        _beneficiary = beneficiary_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function tokensale_open() public view returns (bool) {
        return _cap > totalSupply();
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        _beforeTokenTransfer(sender, amount);

        _balances[sender] = _balances[sender].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        //curate the claimable amount of sender and recipient
        int256 correction = claimableAmountPerToken.mul(amount).toInt256Safe();
        claimableAmountCorrections[sender] = claimableAmountCorrections[sender].add(correction);
        claimableAmountCorrections[recipient] = claimableAmountCorrections[recipient].sub(correction);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "mint to the zero address");

        _beforeTokenTransfer(address(0), amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }


    // function to buy tokens with ETH or DAI / if purchased via ETH - i will be directly exchanged to DAI
    function buyTokens(uint256 daiAmount_) public payable {
        if (msg.value > 0) {
            convertEthToDai(daiAmount_); 
        } else {
            require(_daiInstance.transferFrom(msg.sender, address(this), daiAmount_));
        }
        uint256 tokens = daiAmount_.mul(_rate);
        _mint(msg.sender, tokens);
        emit TokensPurchased(_msgSender(), msg.sender, daiAmount_, tokens);
    }

    //converts ETH to DAI
    function convertEthToDai(uint daiAmount) public payable {
        uint deadline = block.timestamp + 15;
        address[] memory path = new address[](2);
        path[0] = _uniswapRouter.WETH();
        path[1] = _daiToken;

        (uint[] memory amts) = _uniswapRouter.swapETHForExactTokens{ value: msg.value }(daiAmount, path, address(this), deadline);    
        require(amts[0] > 0, "Exchange failed.");
        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }
  
    // important to receive ETH
  receive() payable external {} 

    // function to deliver tokens to buyers who paid without crypto 
    function sendTokens(address buyer, uint256 amount) public {
        require(buyer != address(0), "buyer is a zero address");
        require(amount != 0, "weiAmount is 0");
        
        uint256 tokens = amount.mul(_rate);

        mint(buyer, tokens);
        emit TokensPurchased(_msgSender(), buyer, amount, tokens);
    }

    // security check that just the minter address can mint new tokens
    function mint(address to, uint256 amount) internal {
        require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role to mint");
        _mint(to, amount);
    }

    // check if the cap will be not exceeded with new mint transations
    function _beforeTokenTransfer(address from, uint256 amount) internal virtual {
        if (from == address(0)) { // When minting tokens, check the sale cap
            require(totalSupply().add(amount) <= _cap, "cap exceeded");
        }
    }

    //function to claim the their part of the received reward
    function releaseFunds() public {
        require(tokensale_open() == false, "funds not raised");
        require(fundingReleased == false, "funding already released");
        require(_daiInstance.transfer(_beneficiary, _cap.mul(_rate)), "sending dai failed");
        emit FundsReleased(_beneficiary, _cap);
        fundingReleased = true;
    }

    //functions receives payments from beneficary and calculate and save the claimable amount per token in a magnified manner (to prevent rounding fails)
    function receivePayment(uint256 daiAmount) public {
        require(totalSupply() > 0, "total supply");
        require(_daiInstance.transferFrom(msg.sender, address(this), daiAmount), "DAI Transfer not possible");
        claimableAmountPerToken = claimableAmountPerToken.add((daiAmount).mul(magnitude) / totalSupply());
        emit PaymentReceived(msg.sender, daiAmount);
    }
    

    //function to claim the their part of the received reward
    function withdrawAmount() public {
        uint256 _claimableAmount = claimableAmountOf(msg.sender);
        if (_claimableAmount > 0) {
            withdrawnAmounts[msg.sender] = withdrawnAmounts[msg.sender].add(_claimableAmount);
            require(_daiInstance.transfer(msg.sender, _claimableAmount), "transfer not successful");
            emit AmountPaidOut(msg.sender, _claimableAmount);
        }
    }
    //function to get the amount still to claim
    function claimableAmountOf(address _owner) public view returns(uint256) {
        return accumulativeAmountOf(_owner).sub(withdrawnAmounts[_owner]);
    }
    //function to to get the total amount already withdrawed
    function withdrawnAmountOf(address _owner) public view returns(uint256) {
        return withdrawnAmounts[_owner];
    }
    //function to get the total amount that was claimable 
    function accumulativeAmountOf(address _owner) public view returns(uint256) {
        return claimableAmountPerToken.mul(balanceOf(_owner)).toInt256Safe()
        .add(claimableAmountCorrections[_owner]).toUint256Safe() / magnitude;
    }

}
