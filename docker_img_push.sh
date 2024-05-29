#!/bin/bash

cd backend

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_back

docker build -t tictactoe_back:a12 -t 851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_back:a12 .

docker push 851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_back:a12


cd ../frontend

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_front

docker build -t tictactoe_front:a12 -t 851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_front:a12 .

docker push 851725643716.dkr.ecr.us-east-1.amazonaws.com/tictactoe_front:a12