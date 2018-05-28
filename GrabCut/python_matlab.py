import matlab.engine

eng = matlab.engine.start_matlab()
eng.demo(nargout=0)
eng.quit()
print('finish')
