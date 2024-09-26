FROM node:20-slim

WORKDIR /starter

COPY package.json package-lock.json /starter
COPY . /starter

RUN npm install

CMD ["npm","start"]

EXPOSE 8080
