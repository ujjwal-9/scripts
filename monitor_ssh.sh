#!/bin/bash

echo "Active SSH connections:"
watch -n 1 "sudo lsof -i :22"
