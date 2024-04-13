# Define the file path
file_path = "./tmp/ai.txt"

# Read the entire content of the file into a single string
with open(file_path, "r") as file:
    content = file.read()
    content = content.replace('"', "")

    content = content.replace("[", "")

    content = content.replace("]", "")

    content = content.replace("\n", "")
    quote_list = content.split(",")
    quote_list = [item.strip() for item in quote_list]
    print(quote_list)

# print(quote_list)
