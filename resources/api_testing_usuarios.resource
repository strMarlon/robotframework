*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections
Library    SeleniumLibrary

*** Keywords ***
Criar um usuário novo
    ${palavra_aleatoria}    Generate Random String    length=7    chars=[LETTERS]    #string de apenas letras 
    ${palavra_aleatoria}    Convert To Lower Case    ${palavra_aleatoria}    #convertendo o tamanho
    Set Test Variable       ${EMAIL_TESTE}    ${palavra_aleatoria}@emailteste.com    #todos o passos do teste usaram a variavel
    Log                     ${EMAIL_TESTE}

Cadastrar o usuário criado na ServeRest
    [Arguments]    ${email}     ${status_code_desejado}
    ${body}    Create Dictionary        #CRiando uma variavel json
    ...            nome=Fulano da Silva    
    ...            email=${email}    
    ...            password=123   
    ...            administrador=true

    Log    ${body}

    Criar Sesão na ServeRest

    ${resposta}    POST On Session    
    ...                alias=ServeRest
    ...                url=/usuarios
    ...                json=${body}
    ...                expected_status=${status_code_desejado}
    
    Log    ${resposta.json()}
    IF    ${resposta.status_code} == 201
        Set Test Variable    ${ID_USUARIO}      ${resposta.json()}[_id]  
    END
    Set Test Variable    ${RESPOSTA}        ${resposta.json()}    #variavel global

Criar Sesão na ServeRest
    ${headers}    Create Dictionary    accept=application/json    Content-type=application/json
    Create Session    alias=ServeRest    url=https://serverest.dev    headers=${headers}

Conferir se o usuário foi cadastrado corretamente
    Log   ${RESPOSTA}
    Dictionary Should Contain Item   ${RESPOSTA}     message   Cadastro realizado com sucesso    #confere se a message é a mesma. 
    Dictionary Should Contain Key    ${RESPOSTA}    _id    #verifica se o id existe.


#Test 02
Vou repetir o cadastro do usuário
    Cadastrar o usuário criado na ServeRest    email=${EMAIL_TESTE}    status_code_desejado=400    #passando o parametro da API com ERRO


verificar se a API não permitiu o cadastro repetido
    Dictionary Should Contain Item    ${RESPOSTA}    message    Este email já está sendo usado

Consultar os dados do novo usuário
    ${resposta_consulta}    GET On Session    alias=ServeRest  url=/usuarios/${ID_USUARIO}  expected_status=200    #consutar e pegar o valor do Get
    Set Test Variable    ${RESP_CONSULTA}    ${resposta_consulta.json()}     #Seta o valor e deixa ele global 
Conferir os dados retornados
    Log    ${RESP_CONSULTA} 
    Dictionary Should Contain Item    ${RESP_CONSULTA}    nome                Fulano da Silva
    Dictionary Should Contain Item    ${RESP_CONSULTA}    email               ${EMAIL_TESTE}
    Dictionary Should Contain Item    ${RESP_CONSULTA}    password            123
    Dictionary Should Contain Item    ${RESP_CONSULTA}    administrador       true
    Dictionary Should Contain Item    ${RESP_CONSULTA}    _id                 ${ID_USUARIO}
    
