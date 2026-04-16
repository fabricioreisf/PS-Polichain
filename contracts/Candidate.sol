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

    // Custom errors
    error NaoEOwner();
    error ProdutoNaoExiste(uint256 id);
    error NomeVazio();
    error ValorZero();
    error QuantidadeZero();
    error EstoqueInsuficiente(uint256 disponivel, uint256 pedido);
    error ValorIncorreto(uint256 enviado, uint256 esperado);
    error SaldoZero();
    error SaqueFalhou();
    
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
        if (bytes(_nome).length == 0) revert NomeVazio();
        if (_preco == 0)              revert ValorZero();
        if (_quantidade == 0)         revert QuantidadeZero();

        ++productCount;
        products[productCount] = Product(productCount, _nome, _preco, _quantidade, true);
        return productCount;
    }

    function alterarPreco(uint256 _produtoId, uint256 _novoPreco) public onlyOwner {
        Product storage p = products[_produtoId];
        if (!p.exists)    revert ProdutoNaoExiste(_produtoId);
        if (_novoPreco == 0) revert ValorZero();
        p.price = _novoPreco;
    }

    function obterProduto(uint256 _produtoId) public view returns (Product memory) {
        if (!products[_produtoId].exists) revert ProdutoNaoExiste(_produtoId);
        return products[_produtoId];
    }
    // Stock management
    function verificarEstoque(uint256 _produtoId) public view returns (uint256) {
        if (!products[_produtoId].exists) revert ProdutoNaoExiste(_produtoId);
        return products[_produtoId].quantity;
    }
    
    function adicionarEstoque(uint256 _produtoId, uint256 _quantidade) public onlyOwner {
        Product storage p = products[_produtoId];
        if (!p.exists)      revert ProdutoNaoExiste(_produtoId);
        if (_quantidade == 0) revert QuantidadeZero();
        p.quantity += _quantidade;
    }


    function removerDoEstoque(uint256 _produtoId, uint256 _quantidade) public onlyOwner {
        Product storage p = products[_produtoId];
        if (!p.exists)                revert ProdutoNaoExiste(_produtoId);
        if (_quantidade == 0)         revert QuantidadeZero();
        if (p.quantity < _quantidade) revert EstoqueInsuficiente(p.quantity, _quantidade);
        p.quantity -= _quantidade;
    }

    // Sales
    function comprar(uint256 _produtoId, uint256 _quantidade) public payable {
        Product storage p = products[_produtoId];
        if (!p.exists)                revert ProdutoNaoExiste(_produtoId);
        if (_quantidade == 0)         revert QuantidadeZero();
        if (p.quantity < _quantidade) revert EstoqueInsuficiente(p.quantity, _quantidade);

        uint256 total = p.price * _quantidade;
        if (msg.value != total) revert ValorIncorreto(msg.value, total);

        p.quantity -= _quantidade;
        totalRevenue += total;
        purchases[msg.sender] += total;
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
        uint256 saldo = address(this).balance;
        if (saldo == 0) revert SaldoZero();
        (bool sucesso, ) = payable(owner).call{value: saldo}("");
        if (!sucesso) revert SaqueFalhou();
    }
}