*** Settings ***
Documentation       Realizar comentarios predeterminados en Gamefic

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Netsuite
Library             String
Library             RPA.Robocorp.Vault


*** Variables ***
@{COLUMNAS}=    nuevo    aviso    carrera


*** Tasks ***
Realizar comentarios predeterminados en Gamefic
    Abrir Gamefic App
    Iniciar Sesion
    Comentar Publicacion desde Publicaciones Disponibles


*** Keywords ***
Abrir Gamefic App
    Open Available Browser    https://app.gamefic.me/#/

Iniciar Sesion
    ${secret}=    Get Secret    credentials
    Input Text    input-8    ${secret}[username]
    Input Password    input-11    ${secret}[password]
    Click Button
    ...    //button[@class="ok-button primary--text justify-end v-btn v-btn--has-bg v-btn--rounded theme--light v-size--default accent"]
    Wait Until Page Contains Element    class:timeline-post

Comentar Publicacion desde Publicaciones Disponibles
    ${publicaciones}=    Get WebElements    //a[@role="button"]
    ${miUsuario}=    Set Variable    Jose -
    FOR    ${publicacion}    IN    @{publicaciones}
        Click Element    ${publicacion}
        Sleep    5s
        # Wait Until Page Contains Element    //span[@class="comment-author"]
        ${autores}=    GetWebElements    //span[@class="comment-author"]
        ${esComentado}=    Set Variable    ${0}
        ${titulo}=    Get Text    //div[@class="title px-6"]
        ${titulo}=    Convert To Lower Case    ${titulo}
        FOR    ${autor}    IN    @{autores}
            ${nombre}=    Get Text    ${autor}
            IF    "${nombre}" == "${miUsuario}"
                ${esComentado}=    Set Variable    ${1}
            END
            Log To Console    ${nombre}
        END
        IF    ${esComentado} == 0
            Log To Console    ________No realice comentario______
            Buscar comentario y escribirlo    ${titulo}
            BREAK
        ELSE
            Log To Console    _______Si realice comentario_______
        END
        Press Keys    None    ESC
    END

Buscar comentario y escribirlo
    [Arguments]    ${tipoDeComentario}
    Open Workbook    Comentarios.xlsx
    ${comentarios}=    Read Worksheet As Table    header=True
    Close Workbook
    ${coincideConTitulo}=    Set Variable    ${0}
    FOR    ${columna}    IN    @{COLUMNAS}
        ${esParteDelComentario}=    Evaluate    "${columna}" in """${tipoDeComentario}"""
        IF    ${esParteDelComentario} == True
            ${comentarioElegido}=    Extraer Comentario    ${columna}    ${comentarios}
            ${coincideConTitulo}=    Set Variable    ${1}
            BREAK
        END
        Log    ${columna}
    END
    IF    ${CoincideConTitulo} == 0
        ${comentarioElegido}=    Extraer Comentario    otro    ${comentarios}
    END
    Escribir Comentario    ${comentarioElegido}

Extraer Comentario
    [Arguments]    ${columna}    ${comentarios}
    ${random_position}=    Generate Random String    1    012
    ${random_position}=    Convert To Integer    ${random_position}
    ${comentarioElegido}=    RPA.Tables.Get Table Cell    ${comentarios}    ${random_position}    ${columna}
    Log To Console    ${comentarioElegido}
    RETURN    ${comentarioElegido}

Escribir Comentario
    [Arguments]    ${comentario}
    Input Text    //input[@type="text"]    ${comentario}
    Click Button
    ...    //button[@class="ok-button primary--text justify-end v-btn v-btn--has-bg v-btn--rounded theme--light v-size--default accent"]
