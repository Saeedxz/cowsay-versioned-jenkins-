FROM node

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

EXPOSE $PORT

CMD export PORT=$PORT && npm start



