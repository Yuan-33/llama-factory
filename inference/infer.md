0. git clone git@github.com:Yuan-33/llama-factory.git
1. bash setup_infer.sh
2. export hf = *** (hugging face token)
3. # merge lora model with base model and output in llama-factory/merged_model
   # if llama-factory dont have lora file under /output/lora, find it in chi-uc: https://chi.uc.chameleoncloud.org/project/containers/container/project6_model/lora
 (inside container llama-train) python3 /llama-factory/utils/merge.py 
4. # easy infer: python3 /llama-factory/inference/infer.py (support vllm)
python3 -m vllm.entrypoints.openai.api_server \
  --model ./merged_model \
  --dtype float16 \
  --port 8000 \
  --tokenizer ./merged_model

5. 
curl http://localhost:8000/v1/completions \ \
  -H "Content-Type: application/json" \
  -d '{
    "model": "./merged_model",
    "prompt": "Instruction: What list in an environment?\nInput: def list_states saltenv '\''base'\'' return __context__['\''fileclient''] list_states saltenv\nOutput:",
    "max_tokens": 128,
    "temperature": 0.6
  }'



