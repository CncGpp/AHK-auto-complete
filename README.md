# AHK-auto-complete
Use AHK to suggest and complete words from a trained dictionary as you type. Press CapsLock + Space as you type for enable the current writing word prediction!

This script bases its operation on the python library [autocomplete](https://pypi.org/project/autocomplete/), by default it uses a simple pre-trained model for the English language. See its documentation if you are interested in training on your corpus.



## Usage
1. Install the autocomplete & bottlepy python library

    ```pip install autocomplete```
    
    ```pip install bottle```

2. (optional) Train the autocomplete model with your documents to improve the accuracy and quality of predictions.

3. Run the autocomplete server

    ```python run_server.py```
    
4. You can now through a GET request ask for a prediction. The request format is http://localhost:8080/<text>

5. Run the `AHKautocomplete.ahk` script and press CapsLock + Space as you type for enable the current writing word prediction.
