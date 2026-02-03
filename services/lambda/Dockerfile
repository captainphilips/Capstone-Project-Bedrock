FROM public.ecr.aws/lambda/python:3.11

# Copy dependency definitions
COPY requirements.txt .

# Install dependencies into the Lambda task root
RUN pip install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy application source
COPY src/ ${LAMBDA_TASK_ROOT}

# Set the Lambda handler
CMD ["handler.lambda_handler"]
