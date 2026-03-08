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
        <p>Integração entre CloudFront, ECS Fargate e S3.</p>

        <button id="btn-buscar" onclick="buscar()">Buscar Arquivos</button>

        <h3 id="total"></h3>
        <ul id="lista"></ul>
    </div>
</div>
<script>

const API = "/files"

async function buscar(){

 try{

 const r = await fetch(API)
 const data = await r.json()

 console.log(data)

 document.getElementById("total").innerText =
  "Total de arquivos: " + data.total

 const lista = document.getElementById("lista")
 lista.innerHTML=""

 data.files.forEach(f=>{
   const li = document.createElement("li")
   li.innerText = f
   lista.appendChild(li)
 })

 }catch(e){

 document.getElementById("total").innerText =
  "Erro ao carregar arquivos"

 }

}

</script>

</body>
</html>