from setuptools import setup, find_packages
setup (
	version = "0.3.1",
	name = "asadm",
	packages=find_packages(exclude=['doc', 'test*']),
	include_package_data=True,
	scripts=['asadm.py'],
)
