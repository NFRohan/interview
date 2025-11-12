# JSON AI Code Generator

A production-ready Docker application that processes JSON problem descriptions and generates Python solutions using Google's Gemini AI. The application reads coding problems from JSON files, generates Python code solutions, executes them, and validates the output against expected results.

## 🎯 What It Does

1. **Reads JSON Files**: Processes all `.json` files from the input directory
2. **AI Code Generation**: Uses Gemini AI to generate Python solutions for each problem
3. **Code Execution**: Runs the generated code with test inputs
4. **Validation**: Compares actual output with expected results
5. **Solution Storage**: Saves all generated solutions to files
6. **Rate Limiting**: Implements intelligent delays to avoid API limits
7. **Error Handling**: Robust retry logic for API failures

## 🏗️ Architecture

### Core Components

- **`main.py`**: Main application orchestrating the entire workflow
- **`jsonLoader.py`**: JSON file parsing and loading utility
- **`dockerfile`**: Multi-stage production Docker image
- **`docker-compose.yml`**: Container orchestration configuration

### Docker Configuration

#### **Multi-Stage Build**
```dockerfile
# Builder stage: Install dependencies
FROM python:3.11-slim AS builder
# ... build dependencies and virtual environment

# Production stage: Minimal runtime image
FROM python:3.11-slim AS production
# ... copy only necessary files and run as non-root user
```

#### **Security Features**
- ✅ **Non-root execution**: Runs as `appuser` for security
- ✅ **Read-only filesystem**: Container filesystem is read-only
- ✅ **No new privileges**: Security option prevents privilege escalation
- ✅ **Resource limits**: Memory (1GB) and CPU (0.5 cores) constraints
- ✅ **Health monitoring**: Built-in health checks

#### **Production Optimizations**
- ✅ **Minimal image size**: Multi-stage build reduces final image size
- ✅ **Dependency isolation**: Virtual environment for clean dependencies
- ✅ **Log management**: Structured logging with rotation (10MB max, 3 files)
- ✅ **Restart policy**: `on-failure` - restarts only on errors, not after completion

## 📁 Project Structure

```
json-ai-code-generator/
├── 🐳 Docker Configuration
│   ├── dockerfile                 # Multi-stage production Docker image
│   ├── docker-compose.yml         # Container orchestration
│   └── .dockerignore              # Docker build exclusions
├── 🎯 Application Code
│   ├── main.py                    # Main processing application
│   ├── jsonLoader.py              # JSON file parsing utility
│   └── requirements.txt           # Python dependencies
├── 🚀 Deployment Scripts
│   ├── deploy.ps1                 # Windows PowerShell deployment
│   ├── deploy.sh                  # Linux/macOS Bash deployment
│   └── Makefile                   # Linux/macOS Make commands
├── ⚙️ Configuration
│   ├── .env.example               # Environment variables template
│   └── .gitignore                 # Git exclusions
├── 📂 Input/Output
│   ├── json/                      # Input JSON problem files
│   └── solutions/                 # Generated Python solutions
└── 📚 Documentation
    └── README.md                  # This file
```

## 🚀 Quick Start

### 1. **Environment Setup**
```bash
# Copy environment template
cp .env.example .env

# Edit .env file and add your Gemini API key
# GEMINI_API_KEY=your_actual_api_key_here
```

### 2. **Prepare Input Files**
Create JSON files in the `json/` directory with this format:
```json
{
  "query": "Write a Python program that reads an integer and prints 'YES' if it's even, 'NO' if it's odd.",
  "test_input": 7,
  "test_output": "NO"
}
```

### 3. **Deploy and Run**

#### **Windows (PowerShell)**
```powershell
# Deploy and run
.\deploy.ps1

# Monitor progress
.\deploy.ps1 -Action logs

# Check status
.\deploy.ps1 -Action status
```

#### **Linux/macOS (Bash)**
```bash
# Make script executable
chmod +x deploy.sh

# Deploy and run
./deploy.sh

# Monitor progress
./deploy.sh logs

# Check status
./deploy.sh status
```

#### **Linux/macOS (Make)**
```bash
# Deploy and run
make deploy

# Monitor progress
make logs

# Check status
make status
```

## 📋 Deployment Instructions

### **Prerequisites**

1. **Docker & Docker Compose**: Ensure both are installed and running
2. **Gemini API Key**: Get your API key from Google AI Studio
3. **Environment File**: Configure `.env` with your API key

### **Production Deployment**

#### **Step 1: Clone and Configure**
```bash
git clone <repository-url>
cd json-ai-code-generator
cp .env.example .env
# Edit .env and add GEMINI_API_KEY=your_key_here
```

#### **Step 2: Prepare Input Data**
```bash
# Add your JSON problem files to the json/ directory
# Each file should contain: query, test_input, test_output
```

#### **Step 3: Deploy**

**Windows:**
```powershell
# Full deployment
.\deploy.ps1

# Alternative: Manual Docker commands
docker build -t json-processor:latest .
docker-compose up -d
```

**Linux/macOS:**
```bash
# Using deployment script
./deploy.sh

# Using Make
make deploy

# Alternative: Manual Docker commands
docker build -t json-processor:latest .
docker-compose up -d
```

#### **Step 4: Monitor Execution**
```bash
# Real-time logs
docker-compose logs -f

# Check container status
docker-compose ps

# View health status
docker inspect json-processor-prod --format='{{.State.Health.Status}}'
```

#### **Step 5: Retrieve Results**
```bash
# Generated solutions will be in ./solutions/ directory
ls -la solutions/

# Example files:
# solution_1.py, solution_2.py, etc.
```

### **Development vs Production**

| Feature | Development | Production |
|---------|-------------|------------|
| **Restart Policy** | `no` | `on-failure` |
| **Resource Limits** | None | 1GB RAM, 0.5 CPU |
| **Security** | Basic | Non-root, read-only filesystem |
| **Logging** | Console | Structured with rotation |
| **Health Checks** | Disabled | Enabled (30s intervals) |
| **Volume Mounts** | Read-write | Read-only for inputs |

### **Environment Variables**

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `GEMINI_API_KEY` | ✅ | Google Gemini API key | `AIza...` |
| `OPENAI_API_KEY` | ➖ | OpenAI API key (if using OpenAI) | `sk-...` |
| `OPENROUTER_API_KEY` | ➖ | OpenRouter API key (if using OpenRouter) | `sk-or-...` |
| `PYTHONUNBUFFERED` | ➖ | Disable Python buffering | `1` |
| `PYTHONDONTWRITEBYTECODE` | ➖ | Don't create .pyc files | `1` |

## 🤖 AI Provider Configuration

The application supports multiple AI providers. By default, it uses Google Gemini, but you can easily switch to OpenAI or OpenRouter.

### **Current Default (Gemini)**
```python
# In main.py - Current configuration
llm = ChatOpenAI(
    api_key=os.getenv("GEMINI_API_KEY"),
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
    model="gemini-2.5-flash",
)
```

### **Switch to OpenAI**

#### **1. Update Environment**
```bash
# In .env file
OPENAI_API_KEY=sk-your-openai-api-key-here
```

#### **2. Modify main.py**
```python
# Replace the LLM configuration in main.py
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    model="gpt-4",  # or "gpt-3.5-turbo", "gpt-4-turbo", etc.
    temperature=0.1,
)
```

#### **3. Update Requirements**
```bash
# Add to requirements.txt (if not already present)
openai>=1.0.0
```

### **Switch to OpenRouter**

#### **1. Update Environment**
```bash
# In .env file
OPENROUTER_API_KEY=sk-or-your-openrouter-api-key-here
```

#### **2. Modify main.py**
```python
# Replace the LLM configuration in main.py
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    api_key=os.getenv("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1",
    model="anthropic/claude-3.5-sonnet",  # or other available models
    temperature=0.1,
    extra_headers={
        "HTTP-Referer": "https://your-site.com",  # Optional
        "X-Title": "JSON AI Code Generator",      # Optional
    }
)
```

#### **3. Update Requirements**
```bash
# Add to requirements.txt (if not already present)
openai>=1.0.0
```

### **Popular Model Options**

#### **OpenAI Models**
- `gpt-4` - Most capable, higher cost
- `gpt-4-turbo` - Fast and capable
- `gpt-3.5-turbo` - Balanced cost/performance
- `gpt-4o` - Latest multimodal model

#### **OpenRouter Models**
- `anthropic/claude-3.5-sonnet` - Excellent for coding
- `meta-llama/llama-3.1-70b-instruct` - Open source, good performance
- `google/gemini-pro-1.5` - Google's model via OpenRouter
- `openai/gpt-4` - OpenAI models via OpenRouter
- `mistralai/mixtral-8x7b-instruct` - Good balance of speed/quality

### **Configuration Examples**

#### **Multi-Provider Setup**
```python
# main.py - Support multiple providers
import os
from langchain_openai import ChatOpenAI

def get_llm_provider():
    """Select LLM provider based on available API keys"""
    if os.getenv("OPENAI_API_KEY"):
        return ChatOpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            model="gpt-4",
            temperature=0.1,
        )
    elif os.getenv("OPENROUTER_API_KEY"):
        return ChatOpenAI(
            api_key=os.getenv("OPENROUTER_API_KEY"),
            base_url="https://openrouter.ai/api/v1",
            model="anthropic/claude-3.5-sonnet",
            temperature=0.1,
        )
    elif os.getenv("GEMINI_API_KEY"):
        return ChatOpenAI(
            api_key=os.getenv("GEMINI_API_KEY"),
            base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
            model="gemini-2.5-flash",
        )
    else:
        raise ValueError("No API key found. Please set one of: OPENAI_API_KEY, OPENROUTER_API_KEY, GEMINI_API_KEY")

# Use the function
llm = get_llm_provider()
```

#### **Environment-Based Selection**
```bash
# .env file - Set your preferred provider
AI_PROVIDER=openai
OPENAI_API_KEY=sk-your-key-here

# Or
AI_PROVIDER=openrouter
OPENROUTER_API_KEY=sk-or-your-key-here

# Or
AI_PROVIDER=gemini
GEMINI_API_KEY=your-key-here
```

```python
# main.py - Environment-based selection
import os
from langchain_openai import ChatOpenAI

def create_llm():
    provider = os.getenv("AI_PROVIDER", "gemini").lower()
    
    if provider == "openai":
        return ChatOpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            model=os.getenv("OPENAI_MODEL", "gpt-4"),
            temperature=float(os.getenv("AI_TEMPERATURE", "0.1")),
        )
    elif provider == "openrouter":
        return ChatOpenAI(
            api_key=os.getenv("OPENROUTER_API_KEY"),
            base_url="https://openrouter.ai/api/v1",
            model=os.getenv("OPENROUTER_MODEL", "anthropic/claude-3.5-sonnet"),
            temperature=float(os.getenv("AI_TEMPERATURE", "0.1")),
        )
    elif provider == "gemini":
        return ChatOpenAI(
            api_key=os.getenv("GEMINI_API_KEY"),
            base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
            model=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
        )
    else:
        raise ValueError(f"Unsupported AI provider: {provider}")

llm = create_llm()
```

### **Rate Limiting by Provider**

Different providers have different rate limits. You may need to adjust the delays:

```python
# In main.py, adjust these values based on your provider:

# For OpenAI (adjust based on your tier)
retry_delay = 60      # Longer delay for OpenAI
time.sleep(10)        # Shorter delay between problems

# For OpenRouter (varies by model)
retry_delay = 30      # Standard delay
time.sleep(15)        # Medium delay between problems

# For Gemini (current default)
retry_delay = 30      # Standard delay
time.sleep(20)        # Longer delay between problems
```

### **Cost Considerations**

| Provider | Model | Cost (approx) | Speed | Quality |
|----------|-------|----------------|--------|---------|
| **OpenAI** | gpt-4 | $$$ | Medium | Excellent |
| **OpenAI** | gpt-3.5-turbo | $ | Fast | Good |
| **OpenRouter** | claude-3.5-sonnet | $$ | Medium | Excellent |
| **OpenRouter** | llama-3.1-70b | $ | Fast | Good |
| **Gemini** | gemini-2.5-flash | $ | Fast | Good |

### **Deployment with Different Providers**

After modifying the configuration:

```bash
# Rebuild and deploy with new AI provider
docker build -t json-processor:latest .
docker-compose up -d

# Monitor logs to ensure new provider works
docker-compose logs -f
```

### **JSON Input Format**

Each JSON file should contain:
```json
{
  "query": "Problem description for the AI",
  "test_input": "Input data for testing (string, number, or array)",
  "test_output": "Expected output for validation"
}
```

**Examples:**
```json
{
  "query": "Write a program to check if a number is prime",
  "test_input": 17,
  "test_output": "YES"
}
```

```json
{
  "query": "Write a program to reverse a string",
  "test_input": "hello",
  "test_output": "olleh"
}
```

### **Troubleshooting**

#### **Common Issues**

1. **API Rate Limiting**
   - **Symptom**: `503 - model is overloaded` errors
   - **Solution**: App has built-in retry logic with 30s delays

2. **No JSON Files Found**
   - **Symptom**: `Found 0 problems to process`
   - **Solution**: Add `.json` files to the `json/` directory

3. **Container Exits Immediately**
   - **Symptom**: Container status shows `Exited (0)`
   - **Solution**: This is normal! Container completes and exits cleanly

4. **Permission Errors**
   - **Symptom**: Cannot write to solutions directory
   - **Solution**: Check Docker volume mount permissions

#### **Debugging Commands**
```bash
# Check container logs
docker-compose logs --tail=100

# Access container shell (if running)
docker exec -it json-processor-prod /bin/bash

# Check Docker system resources
docker system df

# Clean up Docker resources
docker system prune -f
```

### **Performance Tuning**

#### **Rate Limiting Configuration**
```python
# In main.py, adjust these values:
retry_delay = 30      # Seconds between retries
time.sleep(20)        # Seconds between problems
max_retries = 3       # Maximum retry attempts
```

#### **Resource Limits**
```yaml
# In docker-compose.yml:
deploy:
  resources:
    limits:
      memory: 1G        # Adjust based on needs
      cpus: '0.5'       # Adjust based on needs
```

## 🔧 Management Commands

### **Container Management**

| Action | Windows PowerShell | Linux/macOS Bash | Linux/macOS Make |
|--------|-------------------|------------------|------------------|
| **Deploy** | `.\deploy.ps1` | `./deploy.sh` | `make deploy` |
| **Status** | `.\deploy.ps1 -Action status` | `./deploy.sh status` | `make status` |
| **Logs** | `.\deploy.ps1 -Action logs` | `./deploy.sh logs` | `make logs` |
| **Stop** | `.\deploy.ps1 -Action stop` | `./deploy.sh stop` | `make stop` |
| **Restart** | `.\deploy.ps1 -Action stop && .\deploy.ps1` | `./deploy.sh stop && ./deploy.sh` | `make restart` |

### **Direct Docker Commands**
```bash
# Build image
docker build -t json-processor:latest .

# Run container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop container
docker-compose down

# Remove everything
docker-compose down --volumes --remove-orphans
```

## 🛡️ Security Features

- **🔒 Non-root execution**: Container runs as unprivileged `appuser`
- **📖 Read-only filesystem**: Container filesystem is read-only for security
- **🚫 No new privileges**: Prevents privilege escalation attacks
- **🎯 Minimal attack surface**: Multi-stage build with minimal runtime dependencies
- **📊 Resource constraints**: Memory and CPU limits prevent resource exhaustion
- **🏥 Health monitoring**: Regular health checks ensure container integrity

## 📊 Monitoring & Observability

- **📈 Resource Usage**: Built-in CPU and memory monitoring
- **🏥 Health Checks**: Automated health status verification
- **📝 Structured Logging**: JSON-formatted logs with rotation
- **📊 Progress Tracking**: Real-time progress indicators
- **⚠️ Error Handling**: Comprehensive error reporting and retry logic

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker deployment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.