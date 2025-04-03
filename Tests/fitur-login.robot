*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSON

*** Variables ***
${BASE_URL}    https://staging-sally-api.kbfinansia.com
${LOGIN_ENDPOINT}    /api/cms/v1/auth/login
${EXPECTED_USERNAME}    wahyunusantaraazis
${EXPECTED_PHONE}    085155002098

# Sukses login credentials
${VALID_USERNAME}    wahyunusantaraazis
${VALID_PASSWORD}    Admin123!

# Gagal login credentials
${INVALID_USERNAME}    wahyunusantaraazis
${INVALID_PASSWORD}    Test123!

*** Test Cases ***
Login API - Success Test
    [Documentation]    This test case tests a successful login with valid credentials.
    [Tags]    api
    ${full_url}=    Catenate    SEPARATOR=    ${BASE_URL}    ${LOGIN_ENDPOINT}
    ${login_payload}=    Create Dictionary    username=${VALID_USERNAME}    password=${VALID_PASSWORD}

    ${headers}=    Create Dictionary    Content-Type=application/json

    ${response}=    POST    ${full_url}    json=${login_payload}    headers=${headers}

    Log    ${response.text}

    Should Be Equal As Numbers    ${response.status_code}    200

    # Convert the JSON response to a dictionary using json.loads() from the JSON library
    ${response_data}=    Evaluate    json.loads('''${response.text}''')    json

    ${username}=    Get From Dictionary    ${response_data['data']}    username
    Should Be Equal    ${username}    ${EXPECTED_USERNAME}

    ${phone}=    Get From Dictionary    ${response_data['data']}    phone
    Should Be Equal    ${phone}    ${EXPECTED_PHONE}

Login API - Failure Test
    [Documentation]    This test case tests a failed login with invalid credentials.
    [Tags]    api
    ${full_url}=    Catenate    SEPARATOR=    ${BASE_URL}    ${LOGIN_ENDPOINT}
    ${login_payload}=    Create Dictionary    username=${INVALID_USERNAME}    password=${INVALID_PASSWORD}

    ${headers}=    Create Dictionary    Content-Type=application/json

    ${response}=    POST    ${full_url}    json=${login_payload}    headers=${headers}

    Log    ${response.text}

    Should Be Equal As Numbers    ${response.status_code}    200

    ${response_data}=    Evaluate    json.loads('''${response.text}''')    json

    ${status}=    Get From Dictionary    ${response_data}    status
    Should Be Equal    ${status}    Failed

    ${validation_message}=    Get From Dictionary    ${response_data['validation']}    Login
    Should Be Equal    ${validation_message}    Login Gagal. Username atau password salah

    # distatus code didefine sebagai 400 bad request di robot-framework jika 400 bad request itu dibaca
    # Status kode 400 Bad Request lebih sering digunakan untuk menunjukkan bahwa permintaan yang dikirim oleh klien tidak valid secara keseluruhan, seperti kesalahan sintaksis dalam permintaan HTTP itu sendiri (misalnya, parameter yang hilang, format yang tidak sesuai, atau kesalahan dalam header permintaan).

*** Keywords ***
