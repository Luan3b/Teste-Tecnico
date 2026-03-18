<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DreamSquad - Dashboard</title>
    <link rel="stylesheet" href="style.css">
    <link rel="icon" href="data:,">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>☁️</text></svg>">
</head>
<body>

<header>
    <h1>DreamSquad</h1>
    <p>Arquivos Gerados via Automação S3</p>
</header>

<div class="container">
    <div class="card">
        <h2>Monitor de Logs</h2>
        
        <button id="btn-buscar" onclick="buscar()">Buscar Arquivos</button>

        <h3 id="total"></h3>
        <ul id="lista"></ul>
    </div>
</div>
<script>
const API = "/files"

async function buscar(){
    try {
        const r = await fetch(API)
        const data = await r.json()
        
        console.log(data)
        
        document.getElementById("total").innerText = "Total de arquivos: " + data.total
        
        const lista = document.getElementById("lista")
        lista.innerHTML = ""
        
        if (data.files && data.files.length > 0) {
            data.files.forEach(item => {
                const li = document.createElement("li")
                // Se for objeto, pega a propriedade 'key' ou 'Key'
                if (typeof item === 'object') {
                    li.innerText = item.key || item.Key || JSON.stringify(item)
                } else {
                    li.innerText = item
                }
                lista.appendChild(li)
            })
        } else {
            const li = document.createElement("li")
            li.innerText = "Nenhum arquivo encontrado"
            lista.appendChild(li)
        }
        
    } catch(e) {
        console.error(e)
        document.getElementById("total").innerText = "Erro ao carregar arquivos"
    }
}

// Executar busca ao carregar a página (opcional)
window.onload = buscar
</script>

</body>
</html>