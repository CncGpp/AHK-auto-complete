# AHK-auto-complete
Use AHK to suggest and complete words from a trained dictionary as you type. Press CapsLock + Space as you type for enable the current writing word prediction!

This is a revisited version of the Uberi AHK script [Uberi - Autocomplete](https://github.com/Uberi/Autocomplete)

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

![example](https://i.ibb.co/sqqdfZw/aaaaaaaaaaaaa.png)

6. Use the `Up` and `Down` arrow keys to select an entry if the currently selected one is not the desired word.
7. Press `Enter` or `Tab`  to trigger the completion with the currently selected word. Alternatively, press one of `Alt + 1`, `Alt + 2`, ..., `Alt + 9`, `Alt + 0` to trigger completion with the 1st, 2nd, ..., 9th, and 10th word, repectively.
