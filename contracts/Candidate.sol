// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

contract Candidate {
    
    struct Product {
        uint256 id;
        string name;
        uint256 price;
        uint256 quantity;
        bool exists;
    }
    
    address public owner;
    uint256 public productCount;
    uint256 public totalRevenue;
    mapping(uint256 => Product) public products;
    mapping(address => uint256) public purchases;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    } 

    constructor() {
        owner = msg.sender;
    }

    // Product management
    function registrarProduto(string memory _nome, uint256 _preco, uint256 _quantidade) public onlyOwner returns (uint256) {
        require(bytes(_nome).length > 0, "Product name shall not be empty");
        require(_preco > 0, "Price must be greater than 0");
        require(_quantidade > 0, "Quantity must be greater than 0");

        productCount++;
        products[productCount] = Product(productCount, _nome, _preco, _quantidade, true);
        return productCount;
    }

    function alterarPreco(uint256 _produtoId, uint256 _novoPreco) public onlyOwner {
        require(products[_produtoId].exists, "Product does not exist");
        require(_novoPreco > 0, "Price must be greater than 0");
        products[_produtoId].price = _novoPreco;
    }

    function obterProduto(uint256 _produtoId) public view returns (Product memory) {
        require(products[_produtoId].exists, "Product does not exist");
        return products[_produtoId];
    }

    // Stock management
    function verificarEstoque(uint256 _produtoId) public view returns (uint256) {
        require(products[_produtoId].exists, "Product does not exist");
        return products[_produtoId].quantity;
    }
    
    function adicionarEstoque(uint256 _produtoId, uint256 _quantidade) public onlyOwner {
        require(products[_produtoId].exists, "Product does not exist");
        require(_quantidade > 0, "Quantity must be greater than 0");
        products[_produtoId].quantity += _quantidade;
    }

    function removerDoEstoque(uint256 _produtoId, uint256 _quantidade) public onlyOwner {
        require(products[_produtoId].exists, "Product does not exist");
        require(_quantidade > 0, "Number of products to be removed must be greater than 0");
        require(products[_produtoId].quantity >= _quantidade, "Not enough stock to remove");
        products[_produtoId].quantity -= _quantidade;
    }

    // Sales
    function comprar(uint256 _produtoId, uint256 _quantidade) public payable {
        require(products[_produtoId].exists, "Product does not exist");
        require(_quantidade > 0, "Quantity must be greater than 0");
        require(products[_produtoId].quantity >= _quantidade, "Not enough stock");
        
        uint256 _totalPrice = products[_produtoId].price * _quantidade;

        require(msg.value == _totalPrice, "Value sent must be exactly the purchase total price");

        products[_produtoId].quantity -= _quantidade;
        totalRevenue += _totalPrice;
        purchases[msg.sender] += _totalPrice;
    }

    // Reports
    function obterTotalComprado(address _usuario) public view returns (uint256) {
        return purchases[_usuario];
    }

    function obterReceitaTotal() public view returns (uint256) {
        return totalRevenue;
    }

    function obterSaldo() public view returns (uint256) {
        return address(this).balance;
    }

    // Withdrawals
    function sacar() public onlyOwner {
        require(address(this).balance > 0, "Current contract balance is zero");
        payable(owner).transfer(address(this).balance);
    }
}