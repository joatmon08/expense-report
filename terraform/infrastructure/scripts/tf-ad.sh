#!/bin/bash

## Add API permissions for Microsoft Graph API
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 5f8c59db-677d-491f-a6b8-5f174b11ec1d=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 4e46008b-f24c-477d-8fff-7bb4ec7aafe0=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions c5366453-9fb0-48a5-a156-24f0c49a4b84=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 0e263e50-5827-48a4-b97c-d940288653c7=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions c79f8feb-a9db-4090-85f9-90d820caa0eb=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions bdfbf15f-ee85-4955-8675-146e8e5296b5=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions bc024368-1153-4739-b217-4326f2e966d0=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions f81125ac-d3b7-4573-a3b2-7099cc39df9e=Scope
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 18a4783c-866b-4cc7-a460-3d5e5662c884=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 5b567255-7703-4780-807c-7be8301ae99b=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 62a82d76-70ea-41e2-9197-370581804d09=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 19dbc75e-c2e2-444c-a770-ec69d8559fc7=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions 98830695-27a2-44f7-8c18-0c3ebc9698f6=Role
az ad app permission add --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000 --api-permissions dbaae8cf-10b5-4b86-a4a1-f871c94c6695=Role

## Add API permissions for Azure Key Vault API
az ad app permission add --id ${AZURERM_CLIENT_ID} --api cfa8b339-82a2-471a-a3c9-0fc0be7a4093 --api-permissions f53da476-18e3-4152-8e01-aec403e6edc0=Scope

az ad app permission grant --id ${AZURERM_CLIENT_ID} --api 00000003-0000-0000-c000-000000000000
az ad app permission grant --id ${AZURERM_CLIENT_ID} --api cfa8b339-82a2-471a-a3c9-0fc0be7a4093

## Grant admin consent for Default Directory
az ad app permission admin-consent --id ${AZURERM_CLIENT_ID}