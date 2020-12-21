from bottle import route, run, debug
from autocomplete import models
from autocomplete import predict

def run_server(port_num=8080):
    models.load_models()

    debug(True)

    @route('/<text>')
    def index(text):
        if not text:
            return ''

        print('GET: ', text)
        
        try:
            splitted = text.split()
            if len(splitted) < 2:
                return ''
            else:
                splitted = splitted[-2:]
                p = predict(splitted[0], splitted[1])
        except:
            return ''

        print('PREDICTED: ', p)
        return '\n'.join([w for w, _ in p])
    

    run(host='localhost', port=port_num)
    
run_server()