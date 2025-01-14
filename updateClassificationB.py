import os
from sys import exit
from json import loads
from re import findall
try:
	from requests import get
except:
	def get(url:str, *parameters:None) -> None:
		return None
	print("Cannot import ``get`` from the ``requests`` library. Fetching from URLs will be unavailable. ")
	print("Please try to install the ``requests`` library correctly via ``python -m pip install requests`` or ``apt-get install python3-requests``. ")
try:
	os.chdir(os.path.abspath(os.path.dirname(__file__)))
except:
	pass
EXIT_SUCCESS = 0
EXIT_FAILURE = 1
EOF = (-1)


class ClassificationB:
	def __init__(self:object, s:tuple|list|set|None = None) -> object:
		self.__s = set(s) if isinstance(s, (tuple, list, set)) else set()
		self.__pattern = "^[A-Za-z][A-Za-z0-9_]*(?:\\.[A-Za-z][A-Za-z0-9_]*)+$"
	def __getTxt(self:object, filePath:str) -> str|None: # get ``*.txt`` content
		for coding in ("utf-8", "ANSI", "utf-16", "gbk"): # codings (add more codings here if necessary)
			try:
				with open(filePath, "r", encoding = coding) as f:
					content = f.read()
				return content[1:] if content.startswith("\ufeff") else content # if utf-8 with BOM, remove BOM
			except (UnicodeError, UnicodeDecodeError):
				continue
			except:
				return None
		return None
	def __getUrl(self:object, url:str) -> tuple: # get URL content
		try:
			r = get(url)
			if r is None:
				return (False, "The ``get`` is currently unavailable. ")
			else:
				return (True, r.text)
		except BaseException as e:
			return (False, str(e))
	def configureFile(self:object, filePath:str, updateSwitch:bool = True) -> bool:
		if isinstance(filePath, str) and isinstance(updateSwitch, bool):
			content = self.__getTxt(filePath)
			if isinstance(content, str):
				if not updateSwitch:
					self.__s.clear()
				originalSize = len(self.__s)
				for line in content.splitlines():
					self.__s.update(findall(self.__pattern, line))
				currentSize = len(self.__s)
				sizeDelta = currentSize - originalSize
				print("Successfully updated {0} package name(s) from the file \"{1}\". ".format(sizeDelta, filePath))
				return True
			else:
				print("Failed to update from the file \"{0}\". ".format(filePath))
		else:
			print("The parameters passed are in wrong types. ")
			return False
	def configureUrl(self:object, url:str, updateSwitch:bool = True) -> bool:
		if isinstance(url, str) and isinstance(updateSwitch, bool):
			status, content = self.__getUrl(url)
			if status:
				if not updateSwitch:
					self.__s.clear()
				originalSize = len(self.__s)
				vector = loads(content)
				if isinstance(vector, list):
					for v in vector:
						if isinstance(v, dict) and "name" in v:
							self.__s.update(findall(self.__pattern, v["name"]))
				currentSize = len(self.__s)
				sizeDelta = currentSize - originalSize
				print("Successfully updated {0} package name(s) from the URL \"{1}\". ".format(sizeDelta, url))
				return True
			else:
				print("Failed to update from the URL \"{0}\". Details are as follows. \n\t{1}".format(url, content))
				return False
		else:
			print("The parameters passed are in wrong types. ")
			return False
	def writeTo(self:object, filePath:str, encoding:str = "utf-8") -> bool:
		try:
			with open(filePath, "w", encoding = encoding) as f:
				f.write(str(self))
			print("Successfully wrote {0} lines to the file \"{1}\". ".format(len(self), filePath))
			return True
		except BaseException as e:
			print("Failed to write to the file \"{0}\" due to exceptions. Details are as follows. \n\t{1}".format(filePath, e))
			return False
	def __len__(self:object) -> int:
		return len(self.__s)
	def __str__(self:object) -> str:
		return "\n".join(sorted(self.__s))


def gitPush() -> bool:
	commandlines = ["git add .", "git commit -m Update", "git push"]
	for commandline in commandlines:
		if os.system(commandline) != 0:
			return False
	return True

def main() -> int:
	filePath = "Classification/classificationB.txt"
	url = "https://modules.lsposed.org/modules.json"
	classificationB = ClassificationB()
	bRet = classificationB.configureFile(filePath)
	bRet = classificationB.configureUrl(url) and bRet
	bRet = classificationB.writeTo(filePath) and bRet
	try:
		choice = input("Would you like to upload the file \"{0}\" to GitHub via ``git push`` [Yn]? ").upper() not in ("N", "NO", "0", "FALSE")
	except:
		choice = True
	if choice:
		bRet = gitPush() and bRet
	iRet = EXIT_SUCCESS if bRet else EXIT_FAILURE
	print("Please press the enter key to exit ({0}). ".format(iRet))
	try:
		input()
	except:
		print()
	return iRet



if "__main__" == __name__:
	exit(main())