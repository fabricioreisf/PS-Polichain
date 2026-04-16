# Candidate.sol

Contrato inteligente desenvolvido em Solidity para o **Processo Seletivo Polichain 2026.1** — grupo de extensão em Blockchain da Poli.

Implementa uma loja Web3 com gerenciamento de produtos, controle de estoque, compras em ETH e saque de receita pelo proprietário.

---

## Tecnologias

- **Solidity** `^0.8.28`
- **Remix IDE** (desenvolvimento e testes manuais)
- **Ethereum** (pagamentos em ETH via `msg.value`)

---

## Estrutura do Contrato

### Variáveis de Estado

| Variável | Tipo | Descrição |
|---|---|---|
| `owner` | `address` | Endereço do proprietário (definido no deploy) |
| `productCount` | `uint256` | Contador incremental de produtos cadastrados |
| `totalRevenue` | `uint256` | Receita histórica acumulada em wei |
| `products` | `mapping(uint256 => Product)` | Mapeamento de ID para produto |
| `purchases` | `mapping(address => uint256)` | Total gasto por endereço em wei |

### Struct `Product`

```solidity
struct Product {
    uint256 id;
    string  name;
    uint256 price;
    uint256 quantity;
    bool    exists;
}
```

---

## Funções

### Gerenciamento de Produtos

| Função | Acesso | Descrição |
|---|---|---|
| `registrarProduto(nome, preco, quantidade)` | `onlyOwner` | Cadastra um novo produto e retorna seu ID |
| `alterarPreco(produtoId, novoPreco)` | `onlyOwner` | Atualiza o preço de um produto existente |
| `obterProduto(produtoId)` | Pública | Retorna os dados completos de um produto |

### Controle de Estoque

| Função | Acesso | Descrição |
|---|---|---|
| `verificarEstoque(produtoId)` | Pública | Retorna a quantidade disponível em estoque |
| `adicionarEstoque(produtoId, quantidade)` | `onlyOwner` | Incrementa o estoque de um produto |
| `removerDoEstoque(produtoId, quantidade)` | `onlyOwner` | Decrementa o estoque de um produto |

### Vendas

| Função | Acesso | Descrição |
|---|---|---|
| `comprar(produtoId, quantidade)` | Pública | Realiza uma compra enviando exatamente `preco * quantidade` em ETH |

### Relatórios

| Função | Acesso | Descrição |
|---|---|---|
| `obterTotalComprado(usuario)` | Pública | Retorna o total gasto em wei por um endereço |
| `obterReceitaTotal()` | Pública | Retorna a receita histórica total acumulada |
| `obterSaldo()` | Pública | Retorna o saldo atual do contrato |

### Saques

| Função | Acesso | Descrição |
|---|---|---|
| `sacar()` | `onlyOwner` | Transfere todo o saldo do contrato para o owner |

---

## Regras de Negócio

- Apenas o `owner` pode registrar produtos, alterar preços, gerenciar estoque e sacar fundos.
- Nome de produto não pode ser vazio.
- Preço e quantidade iniciais devem ser maiores que zero.
- Não é possível operar sobre produtos inexistentes.
- O valor enviado na compra deve ser **exatamente** `preco * quantidade`.
- Não é permitido sacar quando o saldo do contrato for zero.

---

## Otimizações Implementadas

- **`Product storage p`** — uso de ponteiro de storage para evitar leituras redundantes e reduzir consumo de gas.
- **Custom Errors** — substituição de strings em `require` por erros tipados (`revert NaoEOwner()`), reduzindo o tamanho do bytecode e o gas consumido em reversões.
- **`call` no saque** — substituição de `transfer()` por `call{value}()`, padrão recomendado atual que evita falhas por limite de gas fixo.
- **`++productCount` inline** — pré-incremento evita variável temporária desnecessária.

---

## Como Usar no Remix IDE

1. Acesse [remix.ethereum.org](https://remix.ethereum.org)
2. Crie um arquivo chamado exatamente `Candidate.sol` no workspace
3. Cole o código do contrato
4. Na aba **Solidity Compiler**, selecione a versão `0.8.28` e compile
5. Na aba **Deploy & Run Transactions**, selecione o ambiente desejado (ex: Remix VM) e clique em **Deploy**
6. Interaja com o contrato pelo painel de funções gerado automaticamente

---

## Autor

Desenvolvido como submissão ao **Processo Seletivo Polichain 2026.1**.  
Polichain — Grupo de Estudos em Blockchain | Escola Politécnica da USP
