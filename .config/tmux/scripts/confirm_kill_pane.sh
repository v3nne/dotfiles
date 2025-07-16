#!/bin/bash

read -p "Kill pane? (Y/n): " answer

if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
  tmux kill-pane
else
  sleep 5
fi

sleep 5
