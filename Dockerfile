FROM public.ecr.aws/lambda/nodejs:20 AS builder
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
RUN npm run build

FROM public.ecr.aws/lambda/nodejs:20 AS runtime
WORKDIR ${LAMBDA_TASK_ROOT}
COPY package*.json .
RUN npm ci --omit=dev
COPY --from=builder /app/dist/ ./
CMD ["main.handler"]